//
//  HideNavigationBarViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

class HideNavigationBarViewController: BaseViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.isNavigationBarHidden == false {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
}

class ShowNavigationBarViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if navigationController?.isNavigationBarHidden == true,
            let nav = navigationController as? NavigationController {
            // fix back button not work when previous bar is hidden
            _ = nav.navigationBar(nav.navigationBar, shouldPush: navigationItem)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
