//
//  ImageDetailPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

class ImageDetailPresenter: NSObject {
    
    @IBOutlet weak var deleteAlertView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundButton: UIButton!
    
    typealias Section = AnimatableSectionModel<SectionStyle, CellStyle>
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<Section>
    
    var dataSource: DataSource?
    
    func items(events:
        PublishRelay<ImageDetailStateObject.Event>, moreButtonTap: PublishRelay<Void>) -> (Observable<[Section]>) -> Disposable {
            dataSource = DataSource(
                configureCell: { dataSource, collectionView, indexPath, cellStyle in
                    switch cellStyle {
                    case .imageDetail(let item):
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageDetailCell", for: indexPath) as! ImageDetailCell
                        cell.configure(
                            with: item,
                            onStarButtonTap: { events.accept(.onTriggerStarMedium) },
                            onCommentsTap: { events.accept(.onTriggerShowComments(item._id)) },
                            onImageViewTap: { events.accept(.onTriggerPop) },
                            onUserTap: {
                                guard let userId = item.user?._id else { return }
                                events.accept(.onTriggerShowUser(userId))
                        }, onMoreTap: { moreButtonTap.accept(()) }
                        )
                        return cell
                    case .imageTag(let tag):
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
                        cell.tagLabel.text = tag
                        cell.setSelected(true)
                        return cell
                    case .recommendMedium(let item):
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeImageCell", for: indexPath) as! HomeImageCell
                        cell.configure(
                            with: item,
                            onCommentsTap: { events.accept(.onTriggerShowComments(item._id)) },
                            onImageViewTap: { events.accept(.onTriggerShowImage(item._id)) },
                            onUserTap: {
                                guard let userId = item.user?._id else { return }
                                events.accept(.onTriggerShowUser(userId))
                        })
                        return cell
                    }
            },
                configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                    return UICollectionReusableView()
            })
        return collectionView.rx.items(dataSource: dataSource!)
    }
}

extension ImageDetailPresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let dataSource = dataSource else { return .zero }
        switch dataSource[indexPath] {
        case .imageDetail(let medium):
            guard !medium.isInvalidated else { return .zero }
            let width = collectionView.bounds.width
            let imageHeight = width / CGFloat(medium.detail?.aspectRatio.value ?? 1)
            let height = imageHeight + 8 + 56 + 48 + 1 + 48
            return CGSize(width: width, height: height)
        case .imageTag(let tag):
            let textSize = (tag as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
            return CGSize(width: textSize.width + 34, height: textSize.height + 16)
        case .recommendMedium(let medium):
            guard !medium.isInvalidated else { return .zero }
            let width = collectionView.bounds.width - 16
            let imageHeight = width / CGFloat(medium.detail?.aspectRatio.value ?? 1)
            let height = imageHeight + 8 + 56
            return CGSize(width: width, height: height)
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
            return UIEdgeInsets(top: 0, left: 8, bottom: 64, right: 8)
        }
    }
}

extension ImageDetailPresenter {
    
    enum SectionStyle: String {
        case imageDetail
        case imageTags
        case recommendMedia
    }
    
    enum CellStyle {
        case imageDetail(MediumObject)
        case imageTag(String)
        case recommendMedium(MediumObject)
    }
}

extension ImageDetailPresenter.CellStyle {
    
    var recommendMediumId: String? {
        if case .recommendMedium(let medium) = self {
            return medium._id
        }
        return nil
    }
}

extension ImageDetailPresenter.SectionStyle: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        return rawValue
    }
}

extension ImageDetailPresenter.CellStyle: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        switch self {
        case .imageDetail:
            return "imageDetail"
        case .imageTag(let tag):
            return "imageTag.\(tag)"
        case .recommendMedium(let medium):
            return "recommendMedium.\(medium._id)"
        }
    }
    
    static func ==(lhs: ImageDetailPresenter.CellStyle, rhs: ImageDetailPresenter.CellStyle) -> Bool {
        switch (lhs, rhs) {
        case (.imageDetail, imageDetail):
            return false
        case (.recommendMedium(let lMedium), .recommendMedium(let rMedium)):
            return lMedium._id == rMedium._id
        default:
            return false
        }
    }
    
}

