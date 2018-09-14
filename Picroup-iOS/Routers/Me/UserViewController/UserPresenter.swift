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
    var myMediaPresenter: MediaPreserter!

    @IBOutlet weak var hideDetailLayoutConstraint: NSLayoutConstraint!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        self.myMediaPresenter = MediaPreserter(collectionView: myMediaCollectionView, animatedDataSource: true)
        prepareNavigationItems()
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
            guard let user = user, !user.isInvalidated else {
                return
            }
            presenter.userAvatarImageView.setUserAvatar(with: user)
            presenter.navigationItem?.titleLabel.text = user.displayNameDisplay
            presenter.navigationItem?.detailLabel.text = user.usernameDisplay
            presenter.reputationCountLabel.text = user.reputationDisplay
            presenter.followersCountLabel.text = user.followersCountDisplay
            presenter.followingsCountLabel.text = user.followingsCountDisplay
            StarButtonPresenter.isSelected(base: presenter.followButton).onNext(user.isFollowed)
        }
    }
    
    
    var isUserMediaEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.myMediaCollectionView.backgroundView = isEmpty ? presenter.myMediaEmptyView : nil
        }
    }
}
