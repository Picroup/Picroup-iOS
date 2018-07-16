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
    @IBOutlet weak var myStardMediaCollectionView: UICollectionView!
    @IBOutlet weak var myMediaEmptyView: UIView!
    @IBOutlet weak var myStardMediaEmptyView: UIView!

    @IBOutlet weak var selectMyMediaLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideDetailLayoutConstraint: NSLayoutConstraint!
    private var isFirstTimeSetSelectedTab = true
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        
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
        return { loadState in
            return DataSource(
                configureCell: { dataSource, collectionView, indexPath, item in
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                    cell.configure(with: item)
                    return cell
            },
                configureSupplementaryView: createLoadFooterSupplementaryView(loadState: loadState)
            )
        }
    }
    
    var myMediaItems: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [myMediaCollectionView] loadState in
            let dataSource = self.dataSourceFactory(loadState)
            self.myMediaDataSource = dataSource
            return myMediaCollectionView!.rx.items(dataSource: dataSource)
        }
    }
    
    var myStaredMediaItems: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [myStardMediaCollectionView] loadState in
            let dataSource = self.dataSourceFactory(loadState)
            self.myStaredMediaDataSource = dataSource
            return myStardMediaCollectionView!.rx.items(dataSource: dataSource)
        }
    }
    
    var isMyMediaEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.myMediaCollectionView.backgroundView = isEmpty ? presenter.myMediaEmptyView : nil
        }
    }
    
    var isMyStaredMediaEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.myStardMediaCollectionView.backgroundView = isEmpty ? presenter.myStardMediaEmptyView : nil
        }
    }
}


extension MePresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == myMediaCollectionView {
            let aspectRatio = myMediaDataSource?[indexPath].detail?.aspectRatio.value ?? 1
            return CollectionViewLayoutManager.size(in: collectionView.bounds, aspectRatio: aspectRatio)
        } else if collectionView == myStardMediaCollectionView {
            let aspectRatio = myStaredMediaDataSource?[indexPath].detail?.aspectRatio.value ?? 1
            return CollectionViewLayoutManager.size(in: collectionView.bounds, aspectRatio: aspectRatio)
        }
        return .zero
    }
}
