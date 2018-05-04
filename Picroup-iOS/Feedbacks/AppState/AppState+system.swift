//
//  AppState+system.swift
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

extension DriverFeedback where State == AppState {
    
    static func system(window: UIWindow, store: AppStore, storage: LocalStorage) -> ([Raw]) -> Disposable {
        
        return { feedbacks in
            
            let syncState = DriverFeedback.syncState(store: store)
            let syncLocalStorage = DriverFeedback.syncLocalStorage(storage: storage)
            let showMainViewController = DriverFeedback.showMainViewController(window: window)
            let showLoginViewController = DriverFeedback.showLoginViewController(window: window)

            return Driver<Any>.system(
                initialState: State.empty(user: storage.currentUser),
                reduce: logger(identifier: "\(State.self)")(State.reduce),
                feedback: [syncState, syncLocalStorage, showMainViewController, showLoginViewController]
                ).drive()
        }
    }
}

