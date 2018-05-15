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
    
    static func syncAppState(appStore: AppStore) -> Raw {
        return bind(appStore) { (appStore, state) in Bindings(
            subscriptions: [
                state.map { $0.user?.snapshot }.unwrap().drive(onNext: appStore.onLogin),
                ],
            events: [
                Signal.never()
            ])
        }
    }
}
