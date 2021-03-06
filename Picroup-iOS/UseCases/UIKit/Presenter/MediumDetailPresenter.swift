//
//  MediumDetailPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MediumDetailPresenter: NSObject {
    private weak var _collectionView: UICollectionView?
    
    typealias Section = AnimatableSectionModel<SectionStyle, CellStyle>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    fileprivate var dataSource: DataSource?

    init(collectionView: UICollectionView) {
        _collectionView = collectionView
        super.init()
        setup(collectionView: collectionView)
    }
    
    private func setup(collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "ImageDetailCell", bundle: nil), forCellWithReuseIdentifier: "ImageDetailCell")
        collectionView.register(UINib(nibName: "VideoDetailCell", bundle: nil), forCellWithReuseIdentifier: "VideoDetailCell")
        collectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
        collectionView.register(UINib(nibName: "RankMediumCell", bundle: nil), forCellWithReuseIdentifier: "RankMediumCell")
        collectionView.register(UINib(nibName: "RankVideoCell", bundle: nil), forCellWithReuseIdentifier: "RankVideoCell")
    }
    
    func items(
        isSharing: Driver<Bool>,
        onStarButtonTap: ((String) -> Void)?,
        onCommentsTap: ((String) -> Void)?,
        onImageViewTap: ((String) -> Void)?,
        onUserTap: ((String) -> Void)?,
        onShareTap: ((String) -> Void)?,
        onMoreTap: ((String) -> Void)?
        )
        -> (Observable<[Section]>) -> Disposable {
        dataSource = DataSource(
            configureCell: configureCell(
                isSharing: isSharing,
                onStarButtonTap: onStarButtonTap,
                onCommentsTap: onCommentsTap,
                onImageViewTap: onImageViewTap,
                onUserTap: onUserTap,
                onShareTap: onShareTap,
                onMoreTap: onMoreTap
            ),
            configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                return UICollectionReusableView()
        })
        return _collectionView!.rx.items(dataSource: dataSource!)
    }
}

private func configureCell<D>(
    isSharing: Driver<Bool>,
    onStarButtonTap: ((String) -> Void)?,
    onCommentsTap: ((String) -> Void)?,
    onImageViewTap: ((String) -> Void)?,
    onUserTap: ((String) -> Void)?,
    onShareTap: ((String) -> Void)?,
    onMoreTap: ((String) -> Void)?
    )
    -> (D, UICollectionView, IndexPath, MediumDetailPresenter.CellStyle) -> UICollectionViewCell {
    return { dataSource, collectionView, indexPath, cellStyle in
        switch cellStyle {
        case .imageDetail(let item):
            return configureMediumDetailCell(
                isSharing: isSharing,
                onStarButtonTap: onStarButtonTap,
                onCommentsTap: onCommentsTap,
                onImageViewTap: onImageViewTap,
                onUserTap: onUserTap, onShareTap:
                onShareTap,
                onMoreTap: onMoreTap
                )(dataSource, collectionView, indexPath, item)
        case .imageTag(let tag):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
            cell.tagLabel.text = tag
            cell.setSelected(true)
            return cell
        case .recommendMedium(let item):
            return configureMediumCell(onStarButtonTap: onStarButtonTap)(dataSource, collectionView, indexPath, item)
        }
    }
}

private func configureMediumDetailCell<D>(
    isSharing: Driver<Bool>,
    onStarButtonTap: ((String) -> Void)?,
    onCommentsTap: ((String) -> Void)?,
    onImageViewTap: ((String) -> Void)?,
    onUserTap: ((String) -> Void)?,
    onShareTap: ((String) -> Void)?,
    onMoreTap: ((String) -> Void)?
    ) -> (D, UICollectionView, IndexPath, MediumObject) -> UICollectionViewCell {
    return { dataSource, collectionView, indexPath, item in
        let createImageDetailCell: () -> UICollectionViewCell = {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageDetailCell", for: indexPath) as! ImageDetailCell
            cell.configure(
                with: item,
                isSharing: isSharing,
                onStarButtonTap: onStarButtonTap,
                onCommentsTap: onCommentsTap,
                onImageViewTap: onImageViewTap,
                onUserTap: onUserTap,
                onShareTap: onShareTap,
               onMoreTap: onMoreTap
            )
            return cell
        }
        let createVideoDetailCell: () -> UICollectionViewCell = {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoDetailCell", for: indexPath) as! VideoDetailCell
            cell.configure(
                with: item,
                isSharing: isSharing,
                onStarButtonTap: onStarButtonTap,
                onCommentsTap: onCommentsTap,
                onImageViewTap: onImageViewTap,
                onUserTap: onUserTap,
                onShareTap: onShareTap,
                onMoreTap: onMoreTap
            )
            return cell
        }
        guard !item.isInvalidated else { return createImageDetailCell() }
        switch item.kind {
        case MediumKind.video.rawValue?:
            return createVideoDetailCell()
        default:
            return createImageDetailCell()
        }
    }
}

extension MediumDetailPresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let dataSource = dataSource else { return .zero }
        switch dataSource[indexPath] {
        case .imageDetail(let medium):
            guard !medium.isInvalidated else { return .zero }
            let width = collectionView.bounds.width
            let imageHeight = width / CGFloat(medium.detail?.aspectRatio.value ?? 1)
            let height = imageHeight + 2 + 56 + 48 + 1 + 48
            return CGSize(width: width, height: height)
        case .imageTag(let tag):
            let textSize = (tag as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            return CGSize(width: textSize.width + 34, height: textSize.height + 16)
        case .recommendMedium(let medium):
            return CollectionViewLayoutManager.size(in: collectionView.bounds, with: medium)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let dataSource = dataSource else { return .zero }
        switch dataSource[section].model {
        case .imageDetail:
            return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        case .imageTags:
            return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        case .recommendMedia:
            return UIEdgeInsets(top: 0, left: 2, bottom: 64, right: 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cellStyle = dataSource?[indexPath] {
            switch cellStyle {
            case .recommendMedium(let medium):
                playVideoIfNeeded(cell: cell, medium: medium)
            case .imageDetail(let medium):
                playVideoIfNeeded(cell: cell, medium: medium)
            default:
                break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        resetPlayerIfNeeded(cell: cell)
    }
}
