//
//  RouterService+Me.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Apollo
import Material

extension RouterService {
    
    enum Me {}
}

extension RouterService.Me {

    static func notificationsViewController() -> UIViewController {
        let nvc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        let bnvc = BaseNavigationController(rootViewController: nvc)
        bnvc.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "ic_notifications"), selectedImage: nil)
        bnvc.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        bnvc.tabBarItem.badgeColor = .secondary
        return bnvc
    }
    
    static func meNavigationViewController(isRoot: Bool = false) -> UIViewController {
        let mevc = meViewController()
        let bnvc = BaseNavigationController(rootViewController: mevc)
        bnvc.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "ic_person"), selectedImage: nil)
        bnvc.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        bnvc.tabBarItem.badgeColor = .secondary
        return bnvc
    }
    
    static func meViewController() -> MeViewController {
        let mevc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
        return mevc
    }
    
    static func userViewController(dependency: UserViewController.Dependency) -> UserViewController {
        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        vc.dependency = dependency
        return vc
    }
    
    static func updateUserViewController() -> UpdateUserViewController {
        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "UpdateUserViewController") as! UpdateUserViewController
        return vc
    }
    
    static func reputationsViewController() -> ReputationsViewController {
        let rvc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "ReputationsViewController") as! ReputationsViewController
        return rvc
    }
    
    static func followingsViewController(dependency: FollowingsViewController.Dependency) -> FollowingsViewController {
        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "FollowingsViewController") as! FollowingsViewController
        vc.dependency = dependency
        return vc
    }
    
    static func searchUserViewController() -> SearchUserViewController {
        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "SearchUserViewController") as! SearchUserViewController
        return vc
    }
    
    static func followersViewController(dependency: FollowingsViewController.Dependency) -> FollowersViewController {
        let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        vc.dependency = dependency
        return vc
    }
}
