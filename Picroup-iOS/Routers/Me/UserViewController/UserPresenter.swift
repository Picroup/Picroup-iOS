//
//  UserPresenter.swiftMeViewController
//  Picroup-iOS
//
//  Created by luojie on 2018/5/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

class UserPresenter: NSObject {
    weak var navigationItem: UINavigationItem?
    @IBOutlet weak var imageContentView: CustomIntrinsicContentSizeView!
    @IBOutlet weak var meBackgroundView: UIView! { didSet { meBackgroundView.backgroundColor = .primary } }
    @IBOutlet weak var userAvatarImageView: UIImageView!
    var moreButton: IconButton!

    @IBOutlet weak var reputationCountLabel: UILabel!
    @IBOutlet weak var gainedReputationCountButton: UIButton!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingsButton: UIButton!
    
    @IBOutlet weak var myMediaCollectionView: UICollectionView!
    @IBOutlet weak var myMediaEmptyView: UIView!
    @IBOutlet weak var followButton: FABButton! {
        didSet { followButton.image = Icon.favorite }
    }
    
    @IBOutlet weak var hideDetailLayoutConstraint: NSLayoutConstraint!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareMyMediaCollectionView()
        prepareNavigationItems()
    }
    
    fileprivate func prepareMyMediaCollectionView() {
        
        myMediaCollectionView.register(UINib(nibName: "RankMediumCell", bundle: nil), forCellWithReuseIdentifier: "RankMediumCell")
        myMediaCollectionView.register(UINib(nibName: "RankVideoCell", bundle: nil), forCellWithReuseIdentifier: "RankVideoCell")
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
    
    var user: Binder<UserObject?> {
        return Binder(self) { presenter, user in
            let viewModel = UserViewModel(user: user)
            presenter.userAvatarImageView.setUserAvatar(with: user)
            presenter.navigationItem?.titleLabel.text = viewModel.displayName
            presenter.navigationItem?.detailLabel.text = viewModel.username
            presenter.reputationCountLabel.text = viewModel.reputation
            presenter.followersCountLabel.text = viewModel.followersCount
            presenter.followingsCountLabel.text = viewModel.followingsCount
            StarButtonPresenter.isSelected(base: presenter.followButton).onNext(viewModel.followed)
        }
    }
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var dataSource: DataSource?

    private var dataSourceFactory: (Driver<LoadFooterViewState>) -> DataSource {
        return { footerState in
            let dataSource =  DataSource(
                configureCell: configureMediumCell(),
                configureSupplementaryView: createLoadFooterSupplementaryView(footerState: footerState)
            )
            return dataSource
        }
    }
    
    var myMediaItems: (Driver<LoadFooterViewState>) -> (Observable<[Section]>) -> Disposable {
        return { [myMediaCollectionView] footerState in
            let dataSource = self.dataSourceFactory(footerState)
            self.dataSource = dataSource
            return myMediaCollectionView!.rx.items(dataSource: dataSource)
        }
    }
    
    var isUserMediaEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.myMediaCollectionView.backgroundView = isEmpty ? presenter.myMediaEmptyView : nil
        }
    }
}


extension UserPresenter: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
