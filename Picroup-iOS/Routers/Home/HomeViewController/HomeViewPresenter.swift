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

    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareCollectionView()
        prepareFABButton()
        prepareNavigationItem()
        prepareRefreshControl()
    }
    
    fileprivate func prepareCollectionView() {
        
        collectionView.register(UINib(nibName: "RankMediumCell", bundle: nil), forCellWithReuseIdentifier: "RankMediumCell")
        collectionView.register(UINib(nibName: "RankVideoCell", bundle: nil), forCellWithReuseIdentifier: "RankVideoCell")
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
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var dataSource: DataSource?

    func items(footerState: Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
//        [weak self, collectionView]
        let dataSource = DataSource(
            configureCell: configureMediumCell(),
            configureSupplementaryView: createLoadFooterSupplementaryView(footerState: footerState)
        )
        self.dataSource = dataSource
        return collectionView!.rx.items(dataSource: dataSource)
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

extension HomeViewPresenter: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
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

