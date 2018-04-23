//
//  BaseNavigationController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/13.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa

class BaseNavigationController: NavigationController {

    override func prepare() {
        super.prepare()
        isMotionEnabled = true
        motionNavigationTransitionType = .autoReverse(presenting: .fade)
        prepareNavigationBar()
    }
    
}
extension BaseNavigationController {
    
    fileprivate func prepareNavigationBar() {
        navigationBar.depthPreset = .depth1
        navigationBar.barTintColor = .primary
        (navigationBar as? NavigationBar)?.backButtonImage = Icon.arrowBack?.tint(with: .primaryText)
    }
}
