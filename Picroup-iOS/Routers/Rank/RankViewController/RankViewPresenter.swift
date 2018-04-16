//
//  RankViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

class RankViewPresenter {
    
    var categoryButton: IconButton!
    weak var collectionView: UICollectionView!
    weak var navigationItem: UINavigationItem!

    init(collectionView: UICollectionView, navigationItem: UINavigationItem) {
        self.collectionView = collectionView
        self.navigationItem = navigationItem
        self.setup()
    }
    
    private func setup() {
        prepareCategoryButton()
        prepareNavigationItem()
    }
    
    fileprivate func prepareCategoryButton() {
        categoryButton = IconButton(image: Icon.cm.arrowDownward, tintColor: .primaryText)
        categoryButton.pulseColor = .white
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "全部"
        navigationItem.titleLabel.textColor = .primaryText
//        navigationItem.titleLabel.textAlignment = .left
        navigationItem.leftViews = [categoryButton]
    }
    
}
