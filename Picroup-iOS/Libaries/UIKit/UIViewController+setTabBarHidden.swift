//
//  UIViewController+setTabBarHidden.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import CoreGraphics

extension UITabBarController {
    
    func setTabBarHidden(_ hidden: Bool, animated flag: Bool) {
        guard isTabBarHidden() != hidden else { return }
        let tabBarFrame = tabBar.frame
        let offsetY = hidden ? tabBarFrame.height : -tabBarFrame.height
        let duration = flag ? 0.3 : 0
        UIView.animate(withDuration: duration) {
            self.tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: offsetY)
//            if hidden {
//                self.tabBar.transform = CGAffineTransform(translationX: 0, y: 50)
//            } else {
//                self.tabBar.transform = CGAffineTransform.identity
//            }
        }
    }
    
    func isTabBarHidden() -> Bool {
        return tabBar.frame.origin.y >= self.view.frame.maxY
    }
}
