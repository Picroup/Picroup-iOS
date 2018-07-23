//
//  MePresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

class CustomIntrinsicContentSizeView: UIView {
    @IBInspectable var height: CGFloat = 100.0
    @IBInspectable var width: CGFloat = 100.0
    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: height)
    }
}

class MePresenter: NSObject {
    weak var navigationItem: UINavigationItem?
    @IBOutlet weak var imageContentView: CustomIntrinsicContentSizeView!
    
    @IBOutlet weak var meBackgroundView: UIView! { didSet { meBackgroundView.backgroundColor = .primary } }
    @IBOutlet weak var userAvatarImageView: UIImageView!
    var moreButton: IconButton!
    
    @IBOutlet weak var reputationCountLabel: UILabel!
    @IBOutlet weak var gainedReputationCountButton: UIButton!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    
    @IBOutlet weak var reputationButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingsButton: UIButton!

    @IBOutlet weak var myMediaButton: UIButton!
    @IBOutlet weak var myStaredMediaButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var myMediaCollectionView: UICollectionView!
    @IBOutlet weak var myStaredMediaCollectionView: UICollectionView!
    @IBOutlet weak var myMediaEmptyView: UIView!
    @IBOutlet weak var myStaredMediaEmptyView: UIView!

    @IBOutlet weak var selectMyMediaLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideDetailLayoutConstraint: NSLayoutConstraint!
    private var isFirstTimeSetSelectedTab = true
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareMyMediaCollectionView()
        prepareMyStaredMediaCollectionView()
        prepareNavigationItems()
    }
    
    fileprivate func prepareMyMediaCollectionView() {
        
        myMediaCollectionView.register(UINib(nibName: "RankMediumCell", bundle: nil), forCellWithReuseIdentifier: "RankMediumCell")
        myMediaCollectionView.register(UINib(nibName: "RankVideoCell", bundle: nil), forCellWithReuseIdentifier: "RankVideoCell")
    }
    
    fileprivate func prepareMyStaredMediaCollectionView() {
        
        myStaredMediaCollectionView.register(UINib(nibName: "RankMediumCell", bundle: nil), forCellWithReuseIdentifier: "RankMediumCell")
        myStaredMediaCollectionView.register(UINib(nibName: "RankVideoCell", bundle: nil), forCellWithReuseIdentifier: "RankVideoCell")
    }
    
    
    fileprivate func prepareNavigationItems() {
        guard let navigationItem = navigationItem else { return  }

        navigationItem.titleLabel.text = "..."
        navigationItem.titleLabel.textColor = .primaryText
        navigationItem.titleLabel.textAlignment = .left
        
        navigationItem.detailLabel.text = "@..."
        navigationItem.detailLabel.textColor = .primaryText
        navigationItem.detailLabel.textAlignment = .left
        
        moreButton = IconButton(image: UIImage(named: "ic_more_vert"), tintColor: .primaryText)
        
        navigationItem.leftViews = [imageContentView]
        navigationItem.rightViews = [moreButton]
    }
    
    var me: Binder<UserObject?> {
        return Binder(self) { presenter, me in
            let viewModel = UserViewModel(user: me)
            presenter.userAvatarImageView.setUserAvatar(with: me)
            presenter.navigationItem?.titleLabel.text = viewModel.displayName
            presenter.navigationItem?.detailLabel.text = viewModel.username
            presenter.reputationCountLabel.text = viewModel.reputation
            presenter.followersCountLabel.text = viewModel.followersCount
            presenter.followingsCountLabel.text = viewModel.followingsCount
            presenter.gainedReputationCountButton.setTitle(viewModel.gainedReputationCount, for: .normal)
            presenter.gainedReputationCountButton.isHidden = viewModel.isGainedReputationCountHidden
        }
    }
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var myMediaDataSource: DataSource?
    var myStaredMediaDataSource: DataSource?

    var selectedTabIndex: Binder<Int> {
        return Binder(self) { me, index in
            guard let tab = MeStateObject.Tab(rawValue: index) else { return }
            let offsetX = CGFloat(tab.rawValue) * me.scrollView.frame.width
            let offsetY = me.scrollView.contentOffset.y
            let animated = !me.isFirstTimeSetSelectedTab
            me.isFirstTimeSetSelectedTab = false
            me.scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: animated)
            me.selectMyMediaLayoutConstraint.isActive = tab == .myMedia
            UIView.animate(withDuration: animated ? 0.3 : 0, animations: me.meBackgroundView.layoutIfNeeded)
        }
    }
    
    private var dataSourceFactory: (Driver<LoadFooterViewState>) -> DataSource {
        return { footerState in
            return DataSource(
                configureCell: configureMediumCell(),
                configureSupplementaryView: createLoadFooterSupplementaryView(footerState: footerState)
            )
        }
    }
    
    var myMediaItems: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [myMediaCollectionView] footerState in
            let dataSource = self.dataSourceFactory(footerState)
            self.myMediaDataSource = dataSource
            return myMediaCollectionView!.rx.items(dataSource: dataSource)
        }
    }
    
    var myStaredMediaItems: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [myStaredMediaCollectionView] footerState in
            let dataSource = self.dataSourceFactory(footerState)
            self.myStaredMediaDataSource = dataSource
            return myStaredMediaCollectionView!.rx.items(dataSource: dataSource)
        }
    }
    
    var isMyMediaEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.myMediaCollectionView.backgroundView = isEmpty ? presenter.myMediaEmptyView : nil
        }
    }
    
    var isMyStaredMediaEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.myStaredMediaCollectionView.backgroundView = isEmpty ? presenter.myStaredMediaEmptyView : nil
        }
    }
}


extension MePresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == myMediaCollectionView {
            return CollectionViewLayoutManager.size(in: collectionView.bounds, with: myMediaDataSource?[indexPath])
        } else if collectionView == myStaredMediaCollectionView {
            return CollectionViewLayoutManager.size(in: collectionView.bounds, with: myStaredMediaDataSource?[indexPath])
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == myMediaCollectionView {
            playVideoIfNeeded(cell: cell, medium: myMediaDataSource?[indexPath])
        } else if collectionView == myStaredMediaCollectionView {
            playVideoIfNeeded(cell: cell, medium: myStaredMediaDataSource?[indexPath])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        resetPlayerIfNeeded(cell: cell)
    }
}
