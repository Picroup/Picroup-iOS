//
//  UIView+Material+Rx.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Motion

extension Reactive where Base: UIView {
    
    public func animate(_ animations: MotionAnimation...) -> Binder<Void> {
        return Binder(base) { view,  _ in
            view.layer.animate(animations)
        }
    }
}
