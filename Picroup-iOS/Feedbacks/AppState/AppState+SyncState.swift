//
//  AppState+SyncState.swift
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
    
    static func syncState(store: AppStore) -> Raw {
        return bind(store) { (store, state) in
            Bindings(
                subscriptions: [state.drive(store._state)],
                events: [store._events.asSignal()]
            )
        }
    }
}

class AppStore {
    
    let dispatch: (AppState.Event) -> ()
    let state: Driver<AppState>
    
    fileprivate let _events: PublishRelay<AppState.Event>
    fileprivate let _state: BehaviorRelay<AppState>
    
    fileprivate init(appState: AppState) {
        _events = PublishRelay()
        _state = BehaviorRelay(value: appState)
        
        self.state = _state.asDriver()
        self.dispatch = _events.accept
    }
}

extension AppStore {
    static let shared = AppStore(appState: .empty(user: LocalStorage.standard.currentUser))
}
