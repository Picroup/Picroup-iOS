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
    
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet { prepareRefreshControl() }
    }
    
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .primaryLight
        collectionView.addSubview(refreshControl!)
    }
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var items: (PublishRelay<MyInterestedMediaStateObject.Event>) -> (Observable<[Section]>) -> Disposable {
        return { [collectionView] _events in
            let dataSource = DataSource(
                configureCell: { dataSource, collectionView, indexPath, item in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeImageCell", for: indexPath) as! HomeImageCell
                    cell.configure(
                        with: item,
                        onCommentsTap: { _events.accept(.onTriggerShowComments(item._id)) },
                        onImageViewTap: { _events.accept(.onTriggerShowImage(item._id)) },
                        onUserTap: {
//                            _events.accept(.onTriggerShowUser(indexPath.row))
                    }
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

