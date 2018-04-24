//
//  HideNavigationBarViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

class HideNavigationBarViewController: UIViewController {
    
    private var previousNavigationBarHidden: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        previousNavigationBarHidden = navigationController?.isNavigationBarHidden
        if previousNavigationBarHidden == false {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if previousNavigationBarHidden == false {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}
