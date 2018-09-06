//
//  PrimitiveSequence+mapToVoid.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {
    
    public func mapToVoid() -> PrimitiveSequence<SingleTrait, Void> {
        return map { _ in }
    }
}
