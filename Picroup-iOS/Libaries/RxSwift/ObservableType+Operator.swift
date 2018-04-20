//
//  ObservableType+Operator.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift

extension ObservableType {
    
    public func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

