//
//  RankViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

final class RankViewPresenter: NSObject {
    
    var userButton: IconButton!
    var refreshControl: UIRefreshControl!
//    weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    weak var navigationItem: UINavigationItem!
    @IBOutlet weak var hideTagsLayoutConstraint: NSLayoutConstraint!
    var mediaPresenter: MediaPreserter!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        self.mediaPresenter = MediaPreserter(collectionView: collectionView, animatedDataSource: false)
        prepareTagsCollectionView()
        prepareRefreshControl()
        prepareUserButton()
        prepareNavigationItem()
    }
    
    fileprivate func prepareTagsCollectionView() {
        
        tagsCollectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
    }
    
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        collectionView.addSubview(refreshControl!)
    }
    
    fileprivate func prepareUserButton() {
        userButton = IconButton(image: UIImage(named: "baseline_account_circle_black_24pt"), tintColor: .primaryText)
        userButton.pulseColor = .white
        userButton.isHidden = true
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "发现"
        navigationItem.titleLabel.textColor = .primaryText
//        navigationItem.titleLabel.textAlignment = .left
        navigationItem.rightViews = [userButton]
    }
    
}
