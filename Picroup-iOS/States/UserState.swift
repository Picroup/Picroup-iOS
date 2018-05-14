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
    
    var nextMyMediaQuery: MyMediaQuery
    var myMediaItems: [MediumFragment]
    var myMediaError: Error?
    var triggerQueryMyMedia: Bool
    
    var nextShowImageDetailIndex: Int?
    var popQuery: Void?

}

extension UserState {
    var userQuery: UserQuery? {
        if (currentUser == nil) { return nil }
        return triggerQueryUser ? nextUserQuery : nil
    }
    
    var myMediaQuery: MyMediaQuery? {
        if (currentUser == nil) { return nil }
        return triggerQueryMyMedia ? nextMyMediaQuery : nil
    }
    var shouldQueryMoreMyMedia: Bool {
        return !triggerQueryMyMedia && nextMyMediaQuery.cursor != nil
    }
    var isMyMediaItemsEmpty: Bool {
        return !triggerQueryMyMedia && myMediaError == nil && myMediaItems.isEmpty
    }
    var hasMoreMyMedia: Bool {
        return nextMyMediaQuery.cursor != nil
    }
    
    var showImageDetailQuery: MediumFragment? {
        guard let index = nextShowImageDetailIndex else { return nil }
        return myMediaItems[index]
    }
}

extension UserState {
    static func empty(userId: String) -> UserState {
        return UserState(
            currentUser: nil,
            nextUserQuery: UserQuery(userId: userId),
            user: nil,
            userError: nil,
            triggerQueryUser: true,
            
            nextMyMediaQuery: MyMediaQuery(userId: userId),
            myMediaItems: [],
            myMediaError: nil,
            triggerQueryMyMedia: true,
            
            nextShowImageDetailIndex: nil,
            popQuery: nil
        )
    }
}

extension UserState: IsFeedbackState {
    
    enum Event {
        case onUpdateCurrentUser(UserDetailFragment?)
        case onTriggerReloadUser
        case onGetUserSuccess(UserDetailFragment)
        case onGetUserError(Error)
        
        case onTriggerReloadMyMedia
        case onTriggerGetMoreMyMedia
        case onGetMyMediaSuccess(CursorMediaFragment)
        case onGetMyMediaError(Error)
        
        case onTriggerShowImageDetail(Int)
        case onShowImageDetailCompleted
        
        case onPop
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
            
        case .onTriggerReloadMyMedia:
            return state.mutated {
                $0.nextMyMediaQuery.cursor = nil
                $0.myMediaItems = []
                $0.myMediaError = nil
                $0.triggerQueryMyMedia = true
            }
        case .onTriggerGetMoreMyMedia:
            guard state.shouldQueryMoreMyMedia else { return state }
            return state.mutated {
                $0.myMediaError = nil
                $0.triggerQueryMyMedia = true
            }
        case .onGetMyMediaSuccess(let data):
            return state.mutated {
                $0.nextMyMediaQuery.cursor = data.cursor
                $0.myMediaItems += data.items.flatMap { $0.fragments.mediumFragment }
                $0.myMediaError = nil
                $0.triggerQueryMyMedia = false
            }
        case .onGetMyMediaError(let error):
            return state.mutated {
                $0.myMediaError = error
                $0.triggerQueryMyMedia = false
            }
            
        case .onTriggerShowImageDetail(let index):
            return state.mutated {
                $0.nextShowImageDetailIndex = index
            }
        case .onShowImageDetailCompleted:
            return state.mutated {
                $0.nextShowImageDetailIndex = nil
            }
        case .onPop:
            return state.mutated {
                $0.popQuery = ()
            }
        }
    }
}
