//
//  AppState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct AppState: Mutabled {
    var currentUserState: CurrentUserState
}

extension AppState {
    
    static func empty() -> AppState {
        return AppState(
            currentUserState: CurrentUserState()
        )
    }
}

extension AppState: IsFeedbackState {
    enum Event {
        case currentUserEvent(CurrentUserState.Event)
    }
}

extension AppState {
    
    static func reduce(state: AppState, event: Event) -> AppState {
        switch event {
        case .currentUserEvent(let event):
            return state.mutated {
                $0.currentUserState -= event
            }
        }
    }
}
