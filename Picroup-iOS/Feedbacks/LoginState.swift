//
//  AppFeedback.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct LoginState {
    let user: UserQuery.Data.User?
    let isLogin: Bool
    let isExecuting: Bool
    let error: Error?
    let triggerLogin: Void?
}

extension LoginState {
    static var empty: LoginState {
        return LoginState(
            user: nil,
            isLogin: false,
            isExecuting: false,
            error: nil,
            triggerLogin: nil
        )
    }
}

extension LoginState {
    
    enum Event {
        case onExecuting
        case onSuccess(UserQuery.Data.User)
        case onError(Error)
        case onClear
        case onTrigger
    }
}

extension LoginState {
    
    static let reduce: (LoginState, Event) -> LoginState =  { state, event in
        switch event {
        case .onExecuting:
            return LoginState(
                user: nil,
                isLogin: false,
                isExecuting: true,
                error: nil,
                triggerLogin: nil
            )
        case .onSuccess(let user):
            return LoginState(
                user: user,
                isLogin: true,
                isExecuting: false,
                error: nil,
                triggerLogin: nil
            )
        case .onError(let error):
            return LoginState(
                user: nil,
                isLogin: false,
                isExecuting: false,
                error: error,
                triggerLogin: nil
            )
        case .onClear:
            return empty
        case .onTrigger:
            guard shouldLogin(state: state) else { return state }
            return LoginState(
                user: nil,
                isLogin: false,
                isExecuting: false,
                error: nil,
                triggerLogin: ()
            )
        }
    }
    
    private static func shouldLogin(state: LoginState) -> Bool {
        return !state.isExecuting
    }
}


