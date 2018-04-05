//
//  AppState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct AppState {
    var loginState: LoginState
    var routerState: RouterState
}

extension AppState {
    static var empty: AppState {
        return AppState(
            loginState: .empty,
            routerState: .empty
        )
    }
}

extension AppState {
    enum Event {
        case loginEvent(LoginState.Event)
        case routerEvent(RouterState.Event)
    }
}

extension AppState {
    
    static func reduce(state: AppState, event: Event) -> AppState {
        switch event {
        case .loginEvent(let loginEvent):
            let newLoginState = LoginState.reduce(state.loginState, loginEvent)
            return AppState(
                loginState: newLoginState,
                routerState: state.routerState
            )
        case .routerEvent(let routerEvent):
            let newRouterState = RouterState.reduce(state.loginState.isLogin)(state.routerState, routerEvent)
            return AppState(
                loginState: state.loginState,
                routerState: newRouterState
            )
        }
    }
}
