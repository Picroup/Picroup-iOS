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
    
    @IBOutlet weak var reputationCountLabel: UILabel!
    @IBOutlet weak var gainedReputationCountButton: UIButton!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    
//    @IBOutlet weak var myStaredMediaButton: UIButton!
    @IBOutlet weak var myMediaCollectionView: UICollectionView!
    
    @IBOutlet weak var hideDetailLayoutConstraint: NSLayoutConstraint!
    
    typealias Section = AnimatableSectionModel<String, MediumFragment>
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<Section>
    
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

}
