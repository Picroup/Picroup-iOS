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
    var mediaPresenter: MediaPreserter!

    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        self.mediaPresenter = MediaPreserter(collectionView: collectionView, animatedDataSource: false)
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

}
