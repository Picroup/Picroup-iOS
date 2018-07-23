//
//  RaisedButton+Rx.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift
import RxCocoa
import Material

extension Reactive where Base: RaisedButton {
    
    public func isEnabledWithBackgroundColor(_ color: UIColor) -> Binder<Bool> {
        return Binder(base) { button, isEnabled in
            button.isEnabled = isEnabled
            let alpha: CGFloat = isEnabled ? 1 : 0.2
            button.backgroundColor = color.withAlphaComponent(alpha)
        }
    }
}
