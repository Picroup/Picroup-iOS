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

class MePresenter: NSObject {
    @IBOutlet weak var meBackgroundView: UIView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var reputationCountLabel: UILabel!
    @IBOutlet weak var gainedReputationCountButton: UIButton!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var reputationView: UIStackView!
    
    @IBOutlet weak var myMediaButton: UIButton!
    @IBOutlet weak var myStaredMediaButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var myMediaCollectionView: UICollectionView!
    @IBOutlet weak var myStardMediaCollectionView: UICollectionView!

    @IBOutlet weak var selectMyMediaLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var showDetailLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideDetailLayoutConstraint: NSLayoutConstraint!
    
    typealias Section = AnimatableSectionModel<String, MyMediaQuery.Data.User.Medium.Item>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var selectedTab: Binder<MeState.Tab> {
        return Binder(self) { me, tab in
            let offsetX = CGFloat(tab.rawValue) * me.scrollView.frame.width
            let offsetY = me.scrollView.contentOffset.y
            me.scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: true)
            me.selectMyMediaLayoutConstraint.isActive = tab == .myMedia
            UIView.animate(withDuration: 0.3, animations: me.meBackgroundView.layoutIfNeeded)
        }
    }
    
    private var dataSource: DataSource {
        return DataSource(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                let viewModel = RankMediumCell.ViewModel(item: item)
                cell.configure(with: viewModel)
                return cell
        },
            configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                return UICollectionReusableView()
        })
    }
    
    var myMediaItems: (Observable<[Section]>) -> Disposable {
        return myMediaCollectionView.rx.items(dataSource: dataSource)
    }
    
    var myStaredMediaItems: (Observable<[Section]>) -> Disposable {
        return myStardMediaCollectionView.rx.items(dataSource: dataSource)
    }
}

struct UserViewModel {
    let username: String
    let avatarId: String?
    let reputation: String
    let followersCount: String
    let followingsCount: String
    let gainedReputationCount: String
    let isGainedReputationCountHidden: Bool
    
    init(user: UserQuery.Data.User?) {
        self.username = user.map { "@\($0.username)" } ?? " "
        self.avatarId = user?.avatarId
        self.reputation = user?.reputation.description ?? "0"
        self.followersCount = user?.followersCount.description ?? "0"
        self.followingsCount = user?.followingsCount.description ?? "0"
        self.gainedReputationCount = user.map { "+\($0.gainedReputation)" } ?? ""
        self.isGainedReputationCountHidden = user == nil || user!.gainedReputation == 0
    }
}


extension MyMediaQuery.Data.User.Medium.Item: IdentifiableType, Equatable {
    
    public var identity: String {
        return id
    }
    
    public static func ==(lhs: MyMediaQuery.Data.User.Medium.Item, rhs: MyMediaQuery.Data.User.Medium.Item) -> Bool {
        return true
    }
}
