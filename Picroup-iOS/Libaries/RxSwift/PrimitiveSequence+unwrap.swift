//
//  PrimitiveSequence+unwrap.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift

enum UnwrapError: Error {
    case unexpectedNil
}

extension PrimitiveSequence where TraitType == SingleTrait {
    
    public func unwrap<T>() -> PrimitiveSequence<MaybeTrait, T> where Element == T? {
        return filter { $0 != nil }.map { $0! }
    }
    
    public func forceUnwrap<T>() -> PrimitiveSequence<SingleTrait, T> where Element == T? {
        return map {
            guard let value = $0 else { throw UnwrapError.unexpectedNil }
            return value
        }
    }
}

extension ObservableType {
    
    public func unwrap<T>() -> Observable<T> where E == T? {
        return filter { $0 != nil }.map { $0! }
    }
}

