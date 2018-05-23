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
        
        let infos: [(title: String, imageName: String, vc: UIViewController)] = [
            (title: "关注", imageName: "ic_home", vc: homeMenuViewController()),
            (title: "热门", imageName: "ic_apps", vc: rankViewController()),
            (title: "通知", imageName: "ic_notifications", vc: notificationsViewController()),
            (title: "我", imageName: "ic_person", vc: meNavigationViewController()),
            ]
        
        let viewControllers = infos.map { info -> UIViewController in
            let vc = info.vc
            vc.tabBarItem = UITabBarItem(title: info.title, image: UIImage(named: info.imageName), selectedImage: nil)
            return vc
        }
        
        let mvc = MainTabBarController()
        mvc.viewControllers = viewControllers
        mvc.tabBar.isTranslucent = false
//        mvc.selectedIndex = 1
        return mvc
    }
    
    static func homeMenuViewController() -> UIViewController {
        let hvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let hmvc = HomeMenuViewController(rootViewController: hvc)
        return BaseNavigationController(rootViewController: hmvc)
    }
    
    static func rankViewController() -> UIViewController {
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        return BaseNavigationController(rootViewController: rvc)
    }
    
    static func notificationsViewController() -> UIViewController {
        let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        return BaseNavigationController(rootViewController: nvc)
    }
    
    static func meNavigationViewController() -> UIViewController {
        let mevc = meViewController()
        let nvc = BaseNavigationController(rootViewController: mevc)
        nvc.isNavigationBarHidden = true
        return nvc
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
