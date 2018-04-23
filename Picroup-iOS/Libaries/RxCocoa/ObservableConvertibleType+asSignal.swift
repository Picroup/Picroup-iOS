//
//  ObservableConvertibleType+asSignal.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift
import RxCocoa


extension ObservableConvertibleType {
    
    public func asSignalOnErrorRecoverEmpty() -> RxCocoa.SharedSequence<RxCocoa.SignalSharingStrategy, Self.E> {
        return asSignal(onErrorRecover: { _ in RxCocoa.SharedSequence<RxCocoa.SignalSharingStrategy, Self.E>.empty() })
    }
}
