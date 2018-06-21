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
    @IBOutlet weak var meBackgroundView: UIView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!

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
    
    var user: Binder<UserObject?> {
        return Binder(self) { presenter, user in
            let viewModel = UserViewModel(user: user)
            presenter.userAvatarImageView.setUserAvatar(with: user)
            presenter.displaynameLabel.text = viewModel.displayName
            presenter.usernameLabel.text = viewModel.username
            presenter.reputationCountLabel.text = viewModel.reputation
            presenter.followersCountLabel.text = viewModel.followersCount
            presenter.followingsCountLabel.text = viewModel.followingsCount
            StarButtonPresenter.isSelected(base: presenter.followButton).onNext(viewModel.followed)
        }
    }
    
    typealias Section = AnimatableSectionModel<String, MediumObject>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    private var dataSource: (Driver<LoadFooterViewState>) -> DataSource {
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
            return myMediaCollectionView!.rx.items(dataSource: self.dataSource(loadState))
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
        return CollectionViewLayoutManager.size(in: collectionView.bounds)
    }
}
