//
//  UIView+Rx.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    
    public var isShowed: Binder<Bool> {
        return Binder(base) { view, isShowed in
            view.isHidden = !isShowed
        }
    }
}
