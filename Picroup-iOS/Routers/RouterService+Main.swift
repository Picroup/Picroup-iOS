//
//  RouterService+Main.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Apollo
import Material

extension RouterService {
    
    enum Main {}
}

extension RouterService.Main {
    
    static func rootViewController() -> MainTabBarController {
        
        let mvc = MainTabBarController()
        mvc.viewControllers = [
            homeMenuViewController(),
            rankViewController(),
            notificationsViewController(),
            meNavigationViewController(),
        ]
        mvc.tabBar.isTranslucent = false
//        mvc.selectedIndex = 1
        return mvc
    }
    
    static func mainTabBarController() -> MainTabBarController {
        let mvc = MainTabBarController()
        mvc.tabBar.isTranslucent = false
        //        mvc.selectedIndex = 1
        return mvc
        
    }
    
    static func homeMenuViewController() -> UIViewController {
        let hmvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let bnvc = BaseNavigationController(rootViewController: hmvc)
        bnvc.tabBarItem = UITabBarItem(title: "关注", image: UIImage(named: "ic_home"), selectedImage: nil)
        return bnvc
    }
    
    static func rankViewController() -> UIViewController {
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        let bnvc = BaseNavigationController(rootViewController: rvc)
        bnvc.tabBarItem = UITabBarItem(title: "热门", image: UIImage(named: "ic_apps"), selectedImage: nil)
        return bnvc
    }
    
    static func notificationsViewController() -> UIViewController {
        let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        let bnvc = BaseNavigationController(rootViewController: nvc)
        bnvc.tabBarItem = UITabBarItem(title: "通知", image: UIImage(named: "ic_notifications"), selectedImage: nil)
        return bnvc
    }
    
    static func meNavigationViewController() -> UIViewController {
        let mevc = meViewController()
        let bnvc = BaseNavigationController(rootViewController: mevc)
        bnvc.isNavigationBarHidden = true
        bnvc.tabBarItem = UITabBarItem(title: "我", image: UIImage(named: "ic_person"), selectedImage: nil)
        return bnvc
    }
    
    static func meViewController() -> MeViewController {
        let mevc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
        return mevc
    }
    
    static func userViewController(dependency: UserViewController.Dependency) -> UserViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        vc.dependency = dependency
        return vc
    }
    
    static func updateUserViewController() -> UpdateUserViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateUserViewController") as! UpdateUserViewController
        return vc
    }
    
    static func reputationsViewController() -> ReputationsViewController {
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReputationsViewController") as! ReputationsViewController
        return rvc
    }
    
    static func followingsViewController(dependency: FollowingsViewController.Dependency) -> FollowingsViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FollowingsViewController") as! FollowingsViewController
        vc.dependency = dependency
        return vc
    }
    
    static func searchUserViewController() -> SearchUserViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchUserViewController") as! SearchUserViewController
        return vc
    }
    
    static func followersViewController(dependency: FollowingsViewController.Dependency) -> FollowersViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FollowersViewController") as! FollowersViewController
        vc.dependency = dependency
        return vc
    }
}
