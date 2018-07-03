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
    
    public func asSignal(onErrorReturnJust: @escaping (Error) -> Self.E) -> RxCocoa.SharedSequence<RxCocoa.SignalSharingStrategy, Self.E> {
        return asSignal(onErrorRecover: { error in RxCocoa.SharedSequence<RxCocoa.SignalSharingStrategy, Self.E>.just(onErrorReturnJust(error)) })
    }
}


extension ObservableType {
    
    public func catchError(returnJust: @escaping (Error) -> Self.E) -> Observable<E> {
        return catchError { error in .just(returnJust(error)) }
    }
}
