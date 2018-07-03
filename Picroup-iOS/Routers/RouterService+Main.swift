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
            RouterService.Me.notificationsViewController(),
            RouterService.Me.meNavigationViewController(),
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
        bnvc.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "ic_home"), selectedImage: nil)
        bnvc.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        bnvc.tabBarItem.badgeColor = .secondary
        return bnvc
    }
    
    static func rankViewController() -> UIViewController {
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        let bnvc = BaseNavigationController(rootViewController: rvc)
        bnvc.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "ic_apps"), selectedImage: nil)
        bnvc.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        bnvc.tabBarItem.badgeColor = .secondary
        return bnvc
    }
    
    static func feedbackViewController(dependency: FeedbackViewController.Dependency) -> FeedbackViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        vc.dependency = dependency
        return vc
    }
    
    static func aboutAppViewController() -> AboutAppViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutAppViewController") as! AboutAppViewController
        return vc
    }
}
