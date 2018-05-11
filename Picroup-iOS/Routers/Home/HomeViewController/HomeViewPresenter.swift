//
//  HomeViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class HomeViewPresenter: NSObject {
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias Section = AnimatableSectionModel<String, MediumFragment>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var items: (PublishRelay<HomeState.Event>) -> (Observable<[Section]>) -> Disposable {
        return { [collectionView] _events in
            let dataSource = DataSource(
                configureCell: { dataSource, collectionView, indexPath, item in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeImageCell", for: indexPath) as! HomeImageCell
                    cell.configure(
                        with: item,
                        onCommentsTap: { _events.accept(.onTriggerShowComments(indexPath.row)) },
                        onImageViewTap: { _events.accept(.onTriggerShowImageDetail(indexPath.row)) },
                        onUserTap: { _events.accept(.onTriggerShowUser(indexPath.row)) }
                    )
                    return cell
            },
                configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                    return UICollectionReusableView()
            })
            return collectionView!.rx.items(dataSource: dataSource)
        }
    }
}

extension HomeViewPresenter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 16
        let imageHeight = width
        let height = imageHeight + 8 + 56 + 1 + 48
        return CGSize(width: width, height: height)
    }
}

extension MediumFragment: IdentifiableType, Equatable {
    public typealias Identity = String
    public var identity: String {
        return id
    }
    
    public static func ==(lhs: MediumFragment, rhs: MediumFragment) -> Bool {
        return true
    }
}
