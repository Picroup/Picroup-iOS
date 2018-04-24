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
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var reputationCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!

    typealias Section = AnimatableSectionModel<String, MyMediaQuery.Data.User.Medium.Item>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
    var items: (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RankMediumCell", for: indexPath) as! RankMediumCell
                cell.imageView.setImage(with: item.minioId)
                cell.imageView.motionIdentifier = item.id
                cell.transition(.fadeOut, .scale(0.75))
                cell.progressView.progress = Float(item.endedAt.sinceNow / 8.0.weeks)
                cell.progressView.motionIdentifier = "lifeBar_\(item.id)"
                cell.starPlaceholderView.motionIdentifier = "starButton_\(item.id)"
                return cell
        },
            configureSupplementaryView: { dataSource, collectionView, title, indexPath in
                return UICollectionReusableView()
        })
        return collectionView.rx.items(dataSource: dataSource)
    }
}

struct UserViewModel {
    let username: String
    let reputation: String
    let followersCount: String
    let followingsCount: String
    
    init(user: UserQuery.Data.User?) {
        self.username = user.map { "@\($0.username)" } ?? " "
        self.reputation = user?.reputation.description ?? "0"
        self.followersCount = user?.followersCount.description ?? "0"
        self.followingsCount = user?.followingsCount.description ?? "0"
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
