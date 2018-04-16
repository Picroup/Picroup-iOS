//
//  RankToolBarController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/13.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa

class RankNavigationController: NavigationController {

    override func prepare() {
        super.prepare()
        prepareNavigationBar()
    }
    
}
extension RankNavigationController {
    
    fileprivate func prepareNavigationBar() {
        navigationBar.depthPreset = .none
        navigationBar.barTintColor = .primary
        (navigationBar as? NavigationBar)?.backButtonImage = Icon.arrowBack?.tint(with: .primaryText)
    }
}
