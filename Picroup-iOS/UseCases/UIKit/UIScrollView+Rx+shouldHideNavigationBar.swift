//
//  UIScrollView+Rx+shouldHideNavigationBar.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {

    func shouldHideNavigationBar() -> Signal<Bool> {
        return base.rx.willEndDragging.asSignal()
            .flatMapLatest {
                if $0.velocity.y == 0 {
                    return .empty()
                }
                let shouldHide = $0.velocity.y > 0
                return .just(shouldHide)
        }
    }
}
