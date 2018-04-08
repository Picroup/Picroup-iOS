//
//  SharedSequence+Operator.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension SharedSequence {
    
    public func distinctTime<T>() -> SharedSequence<SharingStrategy, T> where E == Timed<T> {
        return distinctUntilChanged { $0.time == $1.time }.map { $0.value }
    }
    
    public func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}
