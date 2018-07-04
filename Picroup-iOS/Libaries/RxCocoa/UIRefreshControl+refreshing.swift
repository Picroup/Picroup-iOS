//
//  UIRefreshControl+refreshing.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIRefreshControl {
    public var refreshing: Binder<Bool> {
        return Binder(self.base) { refreshControl, refresh in
            if refresh {
                refreshControl.beginRefreshingWithAnimation()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }
}

extension UIRefreshControl {
    
    func beginRefreshingWithAnimation() {
        if let scrollView = self.superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - self.frame.height), animated: true)
        }
        self.beginRefreshing()
    }
}
