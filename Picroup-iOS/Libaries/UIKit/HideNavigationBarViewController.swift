//
//  HideNavigationBarViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

class HideNavigationBarViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.isNavigationBarHidden == false {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
}

class ShowNavigationBarViewController: UIViewController {
    
    private var previousNavigationBarHidden: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
