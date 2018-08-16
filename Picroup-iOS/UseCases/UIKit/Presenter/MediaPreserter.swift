//
//  MediaPreserter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MediaPreserter: NSObject {
    private let _animatedDataSource: Bool
    private weak var _collectionView: UICollectionView?
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    fileprivate var dataSource: CollectionViewSectionedDataSource<Section>?

    init(collectionView: UICollectionView, animatedDataSource: Bool) {
        _collectionView = collectionView
        _animatedDataSource = animatedDataSource
        super.init()
        setup(collectionView: collectionView)
    }
    
    private func setup(collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "RankMediumCell", bundle: nil), forCellWithReuseIdentifier: "RankMediumCell")
        collectionView.register(UINib(nibName: "RankVideoCell", bundle: nil), forCellWithReuseIdentifier: "RankVideoCell")
    }
    
    func items(footerState: Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        if _animatedDataSource {
            let _dataSource = RxCollectionViewSectionedAnimatedDataSource<Section>(
                configureCell: configureMediumCell(),
                configureSupplementaryView: createLoadFooterSupplementaryView(footerState: footerState)
            )
            self.dataSource = _dataSource
            return _collectionView!.rx.items(dataSource: _dataSource)
        } else {
            let dataSource =  RxCollectionViewSectionedReloadDataSource<Section>(
                configureCell: configureMediumCell(),
                configureSupplementaryView: createLoadFooterSupplementaryView(footerState: footerState)
            )
            self.dataSource = dataSource
            return _collectionView!.rx.items(dataSource: dataSource)
        }
    }
}

func configureMediumCell<D>() -> (D, UICollectionView, IndexPath, MediumObject) -> UICollectionViewCell {
    return { dataSource, collectionView, indexPath, item in
        let defaultCell: () -> UICollectionViewCell = {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
            cell.configure(with: item)
            return cell
        }
        guard !item.isInvalidated else { return defaultCell() }
        switch item.kind {
        case MediumKind.video.rawValue?:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankVideoCell", for: indexPath) as! RankVideoCell
            cell.configure(with: item)
            return cell
        default:
            return defaultCell()
        }
    }
}

extension MediaPreserter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CollectionViewLayoutManager.size(in: collectionView.bounds, with: dataSource?[indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        playVideoIfNeeded(cell: cell, medium: dataSource?[indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        resetPlayerIfNeeded(cell: cell)
    }
}


func createLoadFooterSupplementaryView<D>(footerState: Driver<LoadFooterViewState>) -> (D, UICollectionView, String, IndexPath) -> UICollectionReusableView {
    return { dataSource, collectionView, title, indexPath in
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CollectionLoadFooterView", for: indexPath) as! CollectionLoadFooterView
        footerState.drive(onNext: footer.contentView.on).disposed(by: footer.disposeBag)
        return footer
    }
}


func playVideoIfNeeded(cell: UICollectionViewCell, medium: MediumObject?) {
    if let vidoeCell = cell as? HasPlayerView, medium?.isInvalidated == false {
        vidoeCell.playerView.play(with: medium?.detail?.videoURL)
    }
}

func resetPlayerIfNeeded(cell: UICollectionViewCell) {
    if let vidoeCell = cell as? HasPlayerView {
        vidoeCell.playerView.reset()
    }
}

extension CollectionViewLayoutManager {
    
    static func size(in bounds: CGRect, with medium: MediumObject?) -> CGSize {
        let aspectRatio: Double
        if let medium = medium, !medium.isInvalidated {
            aspectRatio = medium.detail?.aspectRatio.value ?? 1
        } else {
            aspectRatio = 1
        }
        return CollectionViewLayoutManager.size(in: bounds, aspectRatio: aspectRatio)
    }
}

