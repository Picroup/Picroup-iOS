//
//  UIViewController+Rx+dismiss.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    
    public func dismiss(animated flag: Bool = true, completion: (() -> Swift.Void)? = nil) -> Binder<Void> {
        return Binder(base) { vc, _ in
            vc.dismiss(animated: flag, completion: completion)
        }
    }
    
    public func pop(animated flag: Bool = true, completion: (() -> Swift.Void)? = nil) -> Binder<Void> {
        return Binder(base) { vc, _ in
            vc.navigationController?.popViewController(animated: flag)
        }
    }
}
