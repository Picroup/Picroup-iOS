//
//  SharedSequence+unwrap.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/7.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift
import RxCocoa

extension SharedSequence {
    
    public func unwrap<T>() -> SharedSequence<S, T> where Element == T? {
        return flatMap {
            if let value = $0 {
                return .just(value)
            }
            return .empty()
        }
    }
    
    public func distinctUnwrap<T>() -> SharedSequence<S, T> where Element == T? {
        return distinctUntilChanged { $0 != nil }.unwrap()
    }
}
