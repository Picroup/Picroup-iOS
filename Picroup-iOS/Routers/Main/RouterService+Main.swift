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
    
    static func mainViewController() -> UIViewController {
        
        let infos: [(title: String, imageName: String, vc: UIViewController)] = [
            (title: "主页", imageName: "ic_home", vc: HomeMenuViewController()),
            (title: "排行榜", imageName: "ic_apps", vc: rankViewController()),
            (title: "通知", imageName: "ic_notifications", vc: NotificationsViewController()),
            (title: "我", imageName: "ic_person", vc: MeViewController()),
            ]
        
        let viewControllers = infos.map { info -> UIViewController in
            let vc = info.vc
            vc.tabBarItem = UITabBarItem(title: info.title, image: UIImage(named: info.imageName), selectedImage: nil)
            return vc
        }
        
        let mvc = MainTabBarController()
        mvc.viewControllers = viewControllers
        
        let svc = SnackbarController(rootViewController: mvc)
        return svc
    }
    
    static func rankViewController() -> UIViewController {
        let onSelectCategoryButtonTap = PublishRelay<Void>()
        let category = BehaviorRelay<MediumCategory?>(value: nil)
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RankViewController") as! RankViewController
        rvc.dependency = (category.accept, onSelectCategoryButtonTap.asSignal())
        let rcc = RankContainerController(rootViewController: rvc)
        rcc.dependency = (category.asDriver() , onSelectCategoryButtonTap.accept)
        return rcc
    }
    
    static func selectCategoryViewController(dependency: SelectCategoryViewController.Dependency) -> SelectCategoryViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectCategoryViewController") as! SelectCategoryViewController
        vc.dependency = dependency
        return vc
    }
    
}
