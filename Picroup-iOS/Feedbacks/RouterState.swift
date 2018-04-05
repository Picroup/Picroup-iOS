//
//  RouterState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct RouterState {
    var triggerLogin: Void?
    var triggerShowMedium: String?
}

extension RouterState {
    static var empty: RouterState {
        return RouterState()
    }
}

extension RouterState {
    enum Event {
        case onTriggerLogin
        case onTriggerShowMedium(String)
    }
}

extension RouterState {
    
    static let reduce: (Bool) -> (RouterState, Event) -> RouterState =  { isLogin in { state, event in
        var newState = empty
        switch event {
        case .onTriggerLogin:
            newState.triggerLogin = ()
            return newState
        case .onTriggerShowMedium(let mediumId):
            newState.triggerShowMedium = mediumId
            return newState
        }
    }}
}
