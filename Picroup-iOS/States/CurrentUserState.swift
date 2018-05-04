//
//  CurrentUserState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct CurrentUserState: Mutabled {
    var user: IsUser?
}

extension CurrentUserState {
    var isLogin: Bool {
        return user != nil
    }
    var logoutQuery: Void? {
        return user == nil ? () : nil
    }
}

extension CurrentUserState: IsFeedbackState {
    
    enum Event {
        case login(IsUser)
        case logout
    }
}

extension CurrentUserState {
    static func reduce(state: CurrentUserState, event: CurrentUserState.Event) -> CurrentUserState {
        switch event {
        case .login(let user):
            return state.mutated {
                $0.user = user
            }
        case .logout:
            return state.mutated {
                $0.user = nil
            }
        }
    }
}
