//
//  AppState+SyncLocalStorage.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

extension DriverFeedback where State == AppState {
    
    static func syncLocalStorage(storage: LocalStorage) -> Raw {
        return bind(storage) { (storage, state) in
            return Bindings(
                subscriptions: [
                    state.map { $0.currentUserState.user }.distinctUntilChanged { $0 != nil }.drive(onNext: { storage.currentUser = $0 })
                ],
                events: [.never()]
            )
        }
    }
}
