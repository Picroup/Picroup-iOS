//
//  HomePresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

fileprivate let fabMenuSize = CGSize(width: 56, height: 56)
fileprivate let bottomInset: CGFloat = 74
fileprivate let rightInset: CGFloat = 24

final class HomeViewPresenter: NSObject {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var fabButton: FABButton!
    var addUserButton: IconButton!
    var refreshControl: UIRefreshControl!
    weak var navigationItem: UINavigationItem!
    @IBOutlet weak var emptyView: UIView!
    var mediaPresenter: MediaPreserter!

    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        self.mediaPresenter = MediaPreserter(collectionView: collectionView, animatedDataSource: true)
        prepareFABButton()
        prepareNavigationItem()
        prepareRefreshControl()
    }
    
    fileprivate func prepareFABButton() {
        fabButton = FABButton(image: Icon.cm.add, tintColor: .white)
        fabButton.pulseColor = .white
        fabButton.backgroundColor = .secondary
        
        view.layout(fabButton)
            .bottom(bottomInset)
            .right(rightInset)
            .size(fabMenuSize)
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "关注"
        navigationItem.titleLabel.textColor = .primaryText
        addUserButton = IconButton(image: UIImage(named: "ic_person_add"), tintColor: .primaryText)
        addUserButton.pulseColor = .white
        navigationItem.rightViews = [addUserButton]
    }
    
    fileprivate func prepareRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .primaryLight
        collectionView.addSubview(refreshControl!)
    }
    
    var isMyInterestedMediaEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.collectionView.backgroundView = isEmpty ? presenter.emptyView : nil
        }
    }
    
    var isFabButtonHidden: Binder<Bool> {
        return Binder(self) { presenter, isHidden in
            UIView.animate(withDuration: 0.3) {
                presenter.fabButton.alpha = isHidden ? 0 : 1
            }
        }
    }
}

