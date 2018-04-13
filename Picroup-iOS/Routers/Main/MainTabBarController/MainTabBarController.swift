//
//  MainTabBarController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RankViewController")
        
        let infos: [(title: String, imageName: String, vc: UIViewController)] = [
            (title: "主页", imageName: "ic_home", vc: HomeMenuViewController()),
            (title: "排行榜", imageName: "ic_apps", vc: RankContainerController(rootViewController: rvc)),
            (title: "通知", imageName: "ic_notifications", vc: NotificationsViewController()),
            (title: "我", imageName: "ic_person", vc: MeViewController()),
            ]
        
        viewControllers = infos.map { info in
            let vc = info.vc
            vc.tabBarItem = UITabBarItem(title: info.title, image: UIImage(named: info.imageName), selectedImage: nil)
            return vc
        }
        
        tabBar.isTranslucent = false
    }
}
