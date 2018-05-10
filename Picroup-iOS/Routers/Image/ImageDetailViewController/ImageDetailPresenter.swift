//
//  ImageDetailPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ImageDetailPresenter: NSObject {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundButton: UIButton!
    
    typealias Section = AnimatableSectionModel<String, CellStyle>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var dataSource: DataSource?
    
    func items(
        onStarButtonTap: (() -> Void)?,
        showImageComments: @escaping (ImageDetailState) -> () -> (),
        onImageViewTap: (() -> Void)?,
        showUser: @escaping (ImageDetailState) -> () -> ()
        ) -> (Observable<[Section]>) -> Disposable {
            dataSource = DataSource(
                configureCell: { dataSource, collectionView, indexPath, cellStyle in
                    switch cellStyle {
                    case .imageDetail(let state):
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageDetailCell", for: indexPath) as! ImageDetailCell
                        let viewModel = ImageDetailCell.ViewModel(imageDetailState: state)
                        cell.configure(
                            with: viewModel,
                            onStarButtonTap: onStarButtonTap,
                            onCommentsTap: showImageComments(state),
                            onImageViewTap: onImageViewTap,
                            onUserTap: showUser(state)
                        )
                        return cell
                    case .recommendMedium(let item):
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                        let viewModel = RankMediumCell.ViewModel(item: item)
                        cell.configure(with: viewModel)
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
        case .imageDetail(let state):
            let width = collectionView.bounds.width
            let imageHeight = width / CGFloat(state.item.detail?.aspectRatio ?? 1)
            let height = imageHeight + 8 + 56 + 48 + 48
            return CGSize(width: width, height: height)
        case .recommendMedium:
            return CGSize(width: 184, height: 184)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let dataSource = dataSource else { return .zero }
        switch dataSource[section].model {
        case "recommendMedia":
            return UIEdgeInsets(top: 36, left: 2, bottom: 64, right: 2)
        default:
            return .zero
        }
    }
}

extension ImageDetailPresenter {
    
    enum CellStyle {
        case imageDetail(ImageDetailState)
        case recommendMedium(MediumFragment)
    }
}

extension ImageDetailPresenter.CellStyle: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        switch self {
        case .imageDetail:
            return "imageDetail"
        case .recommendMedium(let medium):
            return medium.id
        }
    }
    
    static func ==(lhs: ImageDetailPresenter.CellStyle, rhs: ImageDetailPresenter.CellStyle) -> Bool {
        switch (lhs, rhs) {
        case (.imageDetail, imageDetail):
            return false
        case (.recommendMedium(let lMedium), .recommendMedium(let rMedium)):
            return lMedium.id == rMedium.id
        default:
            return false
        }
    }
    
}

