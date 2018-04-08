//
//  AppFeedback.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct SessionState {
    let user: UserQuery.Data.User?
    let isLogin: Bool
    let isExecuting: Bool
    let error: Error?
    let triggerLogin: Void?
}

extension SessionState {
    static var empty: SessionState {
        return SessionState(
            user: nil,
            isLogin: false,
            isExecuting: false,
            error: nil,
            triggerLogin: nil
        )
    }
}

extension SessionState {
    
    enum Event {
        case onExecuting
        case onSuccess(UserQuery.Data.User)
        case onError(Error)
        case onClear
        case onTrigger
    }
}

extension SessionState {
    
    static let reduce: (SessionState, Event) -> SessionState =  { state, event in
        switch event {
        case .onExecuting:
            return SessionState(
                user: nil,
                isLogin: false,
                isExecuting: true,
                error: nil,
                triggerLogin: nil
            )
        case .onSuccess(let user):
            return SessionState(
                user: user,
                isLogin: true,
                isExecuting: false,
                error: nil,
                triggerLogin: nil
            )
        case .onError(let error):
            return SessionState(
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
            return SessionState(
                user: nil,
                isLogin: false,
                isExecuting: false,
                error: nil,
                triggerLogin: ()
            )
        }
    }
    
    private static func shouldLogin(state: SessionState) -> Bool {
        return !state.isExecuting
    }
}


