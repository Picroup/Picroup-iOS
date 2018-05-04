//
//  LoginState+Sync.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == LoginState {
    
    static func syncState(store: AppStore) -> Raw {
        return bind(store) { (store, state) in Bindings(
            subscriptions: [
                state.map { $0.user }.unwrap().map { .currentUserEvent(.login($0)) }.drive(onNext: store.dispatch),
                ],
            events: [
                Signal.never()
            ])
        }
    }
}
