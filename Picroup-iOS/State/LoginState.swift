//
//  LoginState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

private let minimalUsernameLength = 5
private let minimalPasswordLength = 5

struct LoginState: Mutabled {
    var username: String
    var password: String
    var user: UserQuery.Data.User?
    var isExecuting: Bool
    var error: Error?
    var triggerLogin: Timed<Void>?
}

extension LoginState {
    var logged: Bool { return user != nil }
    var isUsernameValid: Bool { return username.count > minimalUsernameLength }
    var isPasswordValid: Bool { return password.count > minimalPasswordLength }
    var shouldLogin: Bool { return isPasswordValid && isPasswordValid && !isExecuting }
}

extension LoginState {
    static var empty: LoginState {
        return LoginState(
            username: "",
            password: "",
            user: nil,
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
        case onChangeUsername(String)
        case onChangePassword(String)
    }
}

extension LoginState {
    
    static let reduce: (LoginState, Event) -> LoginState =  { state, event in
        switch event {
        case .onExecuting:
            return state.mutated {
                $0.user = nil
                $0.isExecuting = false
                $0.error = nil
            }
        case .onSuccess(let user):
            return state.mutated {
                $0.user = user
                $0.isExecuting = false
                $0.error = nil
            }
        case .onError(let error):
            return state.mutated {
                $0.user = nil
                $0.isExecuting = false
                $0.error = error
            }
        case .onClear:
            return empty
        case .onTrigger:
            guard state.shouldLogin else { return state }
            return state.mutated {
                $0.user = nil
                $0.isExecuting = false
                $0.error = nil
                $0.triggerLogin = Timed(())
            }
        case .onChangeUsername(let username):
            return state.mutated {
                $0.username = username
            }
        case .onChangePassword(let password):
            return state.mutated {
                $0.password = password
            }
        }
    }
}

