//
//  UIResponder+Rx.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIResponder {
    
    public func resignFirstResponder() -> Binder<Void> {
        return Binder(base) { responder, _ in
            responder.resignFirstResponder()
        }
    }
}

