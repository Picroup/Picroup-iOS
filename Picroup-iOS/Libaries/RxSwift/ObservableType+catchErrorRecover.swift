//
//  ObservableType+catchErrorRecover.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift


extension ObservableType {
    
    public func catchErrorRecoverEmpty() -> RxSwift.Observable<Self.E> {
        return catchError { _ in RxSwift.Observable<Self.E>.empty() }
    }
    
    public func catchErrorRecover(_ recover: @escaping (Error) -> Self.E) -> RxSwift.Observable<Self.E> {
        return catchError { error in RxSwift.Observable<Self.E>.just(recover(error)) }
    }
}

