//
//  HomeViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

class MainTabBarController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        viewControllers = (0...3).lazy
            .map { UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\($0)") }
            .map {
                let vc = HomeViewController(rootViewController: $0)
                vc.tabBarItem = $0.tabBarItem
                return vc
        }
        
        tabBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

class HomeViewController: FABMenuController {
    
    fileprivate var homePresenter: HomePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homePresenter = HomePresenter(view: view, fabMenu: fabMenu)
    }
}
