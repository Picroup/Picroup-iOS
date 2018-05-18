//
//  UIScrollView+Rx+triggerGetMore.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    
    var triggerGetMore: Signal<Void> {
        let scheduler = MainScheduler.instance
        return isNearBottom.skip(1, scheduler: scheduler)
            .throttle(1, latest: false, scheduler: scheduler)
            .asSignalOnErrorRecoverEmpty()
    }
}
