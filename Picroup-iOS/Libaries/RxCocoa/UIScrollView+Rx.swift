//
//  UIScrollView+isNearBottom.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/13.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIScrollView {
    
    public var isNearBottom: Bool {
        return contentSize.height - (contentOffset.y + bounds.height) < 200
    }
}

extension Reactive where Base: UIScrollView {
    
    public var isNearBottom: ControlEvent<Void> {
        let scrollView = base
        let events = didEndDecelerating
            .flatMap { _ -> Observable<Void> in
                scrollView.isNearBottom ? .just(())  : .empty()
        }
        return ControlEvent(events: events)
    }
}
