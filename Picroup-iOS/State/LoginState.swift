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
    var error: Error?
    var triggerLogin: (String, String)?
}

extension LoginState {
    var logged: Bool { return user != nil }
    var isExecuting: Bool { return triggerLogin != nil }
    var isUsernameValid: Bool { return username.count > minimalUsernameLength }
    var isPasswordValid: Bool { return password.count > minimalPasswordLength }
    var shouldLogin: Bool { return isUsernameValid && isPasswordValid && !isExecuting }
}

extension LoginState {
    static var empty: LoginState {
        return LoginState(
            username: "",
            password: "",
            user: nil,
            error: nil,
            triggerLogin: nil
        )
    }
}

extension LoginState {
    
    enum Event {
        case onSuccess(UserQuery.Data.User)
        case onError(Error)
        case onTrigger
        case onChangeUsername(String)
        case onChangePassword(String)
    }
}

extension LoginState {
    
    static let reduce: (LoginState, Event) -> LoginState =  { state, event in
        print("event:", event)
        switch event {
        case .onSuccess(let user):
            return state.mutated {
                $0.user = user
                $0.error = nil
                $0.triggerLogin = nil
            }
        case .onError(let error):
            return state.mutated {
                $0.user = nil
                $0.error = error
                $0.triggerLogin = nil
            }
        case .onTrigger:
            guard state.shouldLogin else { return state }
            return state.mutated {
                $0.user = nil
                $0.error = nil
                $0.triggerLogin = (state.username, state.password)
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

enum LoginError: LocalizedError {
    case usernameOrPasswordIncorrect
}

extension LoginError {
    
    var errorDescription: String {
        switch self {
        case .usernameOrPasswordIncorrect: return "用户名或密码错误"
        }
    }
}

