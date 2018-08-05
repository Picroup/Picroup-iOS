//
//  UIViewController+Rx+NavigationBar.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    
    public func setNavigationBarHidden(animated flag: Bool) -> Binder<Bool> {
        return Binder(base) { vc, hidden in
            vc.navigationController?.setNavigationBarHidden(hidden, animated: flag)
        }
    }
}

extension Reactive where Base: UIViewController {
    
    public func setTabBarHidden(animated flag: Bool) -> Binder<Bool> {
        return Binder(base) { vc, hidden in
            vc.tabBarController?.setTabBarHidden(hidden, animated: flag)
        }
    }
}

