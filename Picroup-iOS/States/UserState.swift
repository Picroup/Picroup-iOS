//
//  UserState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct UserState: Mutabled {
    
    var currentUser: UserDetailFragment?
    
    var nextUserQuery: UserQuery
    var user: UserDetailFragment?
    var userError: Error?
    var triggerQueryUser: Bool
}

extension UserState {
    var userQuery: UserQuery? {
        if (currentUser == nil) { return nil }
        return triggerQueryUser ? nextUserQuery : nil
    }
}

extension UserState {
    static func empty(userId: String) -> UserState {
        return UserState(
            currentUser: nil,
            nextUserQuery: UserQuery(userId: userId),
            user: nil,
            userError: nil,
            triggerQueryUser: true
        )
    }
}

extension UserState: IsFeedbackState {
    
    enum Event {
        case onUpdateCurrentUser(UserDetailFragment?)
        case onTriggerReloadUser
        case onGetUserSuccess(UserDetailFragment)
        case onGetUserError(Error)
    }
}

extension UserState {
    
    static func reduce(state: UserState, event: UserState.Event) -> UserState {
        switch event {
        case .onUpdateCurrentUser(let currentUser):
            return state.mutated {
                $0.currentUser = currentUser
            }
        case .onTriggerReloadUser:
            return state.mutated {
                $0.userError = nil
                $0.triggerQueryUser = true
            }
        case .onGetUserSuccess(let data):
            return state.mutated {
                $0.user = data
                $0.userError = nil
                $0.triggerQueryUser = false
            }
        case .onGetUserError(let error):
            return state.mutated {
                $0.user = nil
                $0.userError = error
                $0.triggerQueryUser = false
            }
        }
    }
}
