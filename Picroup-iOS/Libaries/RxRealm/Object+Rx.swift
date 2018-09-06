//
//  Object+Rx.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxRealm
import RxSwift

extension Reactive where Base: Object {
    
    public func observe(emitInitialValue: Bool = true,
        properties: [String]? = nil) -> Observable<Base> {
        return Observable.from(object: base, emitInitialValue: emitInitialValue, properties: properties)
    }
}

extension Reactive where Base: NotificationEmitter {
    
    public func observe(synchronousStart: Bool = true) -> Observable<Base> {
        return Observable.collection(from: base, synchronousStart: synchronousStart)
    }
}

