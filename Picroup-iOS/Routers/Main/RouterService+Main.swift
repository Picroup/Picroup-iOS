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
    
    static func rootViewController() -> UIViewController {
        
        let infos: [(title: String, imageName: String, vc: UIViewController)] = [
            (title: "匹酷普", imageName: "ic_home", vc: homeMenuViewController()),
            (title: "排行榜", imageName: "ic_apps", vc: rankViewController()),
            (title: "通知", imageName: "ic_notifications", vc: notificationsViewController()),
            (title: "我", imageName: "ic_person", vc: meViewController()),
            ]
        
        let viewControllers = infos.map { info -> UIViewController in
            let vc = info.vc
            vc.tabBarItem = UITabBarItem(title: info.title, image: UIImage(named: info.imageName), selectedImage: nil)
            return vc
        }
        
        let mvc = MainTabBarController()
        mvc.viewControllers = viewControllers
//        mvc.selectedIndex = 1
        let svc = SnackbarController(rootViewController: mvc)
        return svc
    }
    
    static func homeMenuViewController() -> UIViewController {
        let state = BehaviorRelay<HomeState>(value: .empty(userId: Config.userId))
        let events = PublishRelay<HomeState.Event>()
        let hvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        hvc.dependency = (state.asDriver(), events.accept)
        let hmvc = HomeMenuViewController(rootViewController: hvc)
        hmvc.dependency = (state.accept, events.asSignal())
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
    
    static func meViewController() -> UIViewController {
        let mevc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MeViewController") as! MeViewController
        let nvc = BaseNavigationController(rootViewController: mevc)
        nvc.isNavigationBarHidden = true
        return nvc
    }
    
    static func reputationsViewController(dependency: ReputationsViewController.Dependency) -> ReputationsViewController {
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReputationsViewController") as! ReputationsViewController
        rvc.dependency = dependency
        return rvc
    }
    
    
}
