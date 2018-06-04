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
        bnvc.tabBarItem = UITabBarItem(title: "关注", image: UIImage(named: "ic_home"), selectedImage: nil)
        return bnvc
    }
    
    static func rankViewController() -> UIViewController {
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        let bnvc = BaseNavigationController(rootViewController: rvc)
        bnvc.tabBarItem = UITabBarItem(title: "热门", image: UIImage(named: "ic_apps"), selectedImage: nil)
        return bnvc
    }
    
    static func feedbackViewController(dependency: FeedbackViewController.Dependency) -> FeedbackViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        vc.dependency = dependency
        return vc
    }
    
}
