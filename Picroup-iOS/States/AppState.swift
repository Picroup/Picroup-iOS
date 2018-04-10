//
//  AppState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct AppState {
    var user: UserQuery.Data.User?
}

extension AppState {
    enum Event {
        case login(UserQuery.Data.User)
        case logout
    }
}

extension AppState {
    
    static func reduce(state: AppState, event: Event) -> AppState {
        switch event {
        case .login(let user):
            return AppState(user: user)
        case .logout:
            return AppState(user: nil)

        }
    }
}
