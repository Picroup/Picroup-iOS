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
        
        let infos: [(identifier: String, title: String, imageName: String)] = [
            (identifier: "0", title: "主页", imageName: "ic_home"),
            (identifier: "1", title: "排行榜", imageName: "ic_apps"),
            (identifier: "2", title: "通知", imageName: "ic_notifications"),
            (identifier: "3", title: "我", imageName: "ic_person"),
            ]
        
        viewControllers = infos.map { info in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: info.identifier)
            let rvc = info.identifier == "0" ? HomeViewController(rootViewController: vc) : vc
            rvc.tabBarItem = UITabBarItem(title: info.title, image: UIImage(named: info.imageName), selectedImage: nil)
            return rvc
        }
        
        tabBar.isTranslucent = false
    }
}
