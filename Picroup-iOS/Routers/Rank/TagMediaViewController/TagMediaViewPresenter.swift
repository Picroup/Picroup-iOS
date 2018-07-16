//
//  TagMediaViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

final class TagMediaViewPresenter: NSObject {
    
    var refreshControl: UIRefreshControl!
    //    weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!

    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareRefreshControl()
        prepareNavigationItem()
    }
    
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        collectionView.addSubview(refreshControl!)
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = ""
        navigationItem.titleLabel.textColor = .primaryText
    }
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<Section>
    
    var dataSource: DataSource?
    
    var items: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [collectionView] loadState in
            let dataSource = DataSource(
                configureCell: { dataSource, collectionView, indexPath, item in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                    cell.configure(with: item)
                    return cell
            },
                configureSupplementaryView: createLoadFooterSupplementaryView(loadState: loadState)
            )
            self.dataSource = dataSource
            return collectionView!.rx.items(dataSource: dataSource)
        }
    }
    
}

extension TagMediaViewPresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aspectRatio = dataSource?[indexPath].detail?.aspectRatio.value ?? 1
        return CollectionViewLayoutManager.size(in: collectionView.bounds, aspectRatio: aspectRatio)
    }
}
