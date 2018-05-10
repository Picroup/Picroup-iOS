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
    @IBOutlet weak var reputationView: UIStackView!
    
//    @IBOutlet weak var myStaredMediaButton: UIButton!
    @IBOutlet weak var myMediaCollectionView: UICollectionView!
    
    @IBOutlet weak var hideDetailLayoutConstraint: NSLayoutConstraint!

}
