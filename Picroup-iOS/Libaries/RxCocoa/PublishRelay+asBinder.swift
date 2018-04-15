//
//  PublishRelay+asBinder.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension PublishRelay {
    
    public func asBinder(scheduler: ImmediateSchedulerType = MainScheduler()) -> Binder<E> {
        return Binder(self, scheduler: scheduler, binding: { (me, element) in
            print("accept")
            me.accept(element)
        })
    }
}

