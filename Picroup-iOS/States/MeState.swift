//
//  MeState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct MeState: Mutabled {
    typealias Item = MyMediaQuery.Data.User.Medium.Item
    
    var currentUser: IsUser?
    
    var nextMeQuery: UserQuery
    var me: UserQuery.Data.User?
    var meError: Error?
    var triggerQueryMe: Bool
    
    var nextMyMediaQuery: MyMediaQuery
    var myMediaItems: [Item]
    var myMediaError: Error?
    var triggerQueryMyMedia: Bool
    
    var nextShowImageDetailIndex: Int?
    
    var triggerShowReputations: Bool
}

extension MeState {
    var meQuery: UserQuery? {
        if (currentUser == nil) { return nil }
        return triggerQueryMe ? nextMeQuery : nil
    }
    var myMediaQuery: MyMediaQuery? {
        if (currentUser == nil) { return nil }
        return triggerQueryMyMedia ? nextMyMediaQuery : nil
    }
    var shouldQueryMoreMyMedia: Bool {
        return !triggerQueryMyMedia && nextMyMediaQuery.cursor != nil
    }
    var isItemsEmpty: Bool {
        return !triggerQueryMyMedia && myMediaError == nil && myMediaItems.isEmpty
    }
    var hasMore: Bool {
        return nextMyMediaQuery.cursor != nil
    }
    var showImageDetailQuery: Item? {
        guard let index = nextShowImageDetailIndex else { return nil }
        return myMediaItems[index]
    }
    var showReputationsQuery: Int? {
        return triggerShowReputations ? me?.reputation : nil
    }
}

extension MeState {
    static func empty() -> MeState {
        return MeState(
            currentUser: nil,
            nextMeQuery: UserQuery(userId: ""),
            me: nil,
            meError: nil,
            triggerQueryMe: false,
            nextMyMediaQuery: MyMediaQuery(userId: ""),
            myMediaItems: [],
            myMediaError: nil,
            triggerQueryMyMedia: true,
            nextShowImageDetailIndex: nil,
            triggerShowReputations: false
        )
    }
}

extension MeState: IsFeedbackState {
    
    enum Event {
        case onUpdateCurrentUser(IsUser?)
        case onTriggerReloadMe
        case onGetMeSuccess(UserQuery.Data.User)
        case onGetMeError(Error)
        
        case onTriggerReload
        case onTriggerGetMore
        case onGetSuccess(MyMediaQuery.Data.User.Medium)
        case onGetError(Error)
        
        case onTriggerShowImageDetail(Int)
        case onShowImageDetailCompleted
        
        case onTriggerShowReputations
        case onShowReputationsCompleted
    }
}

extension MeState {
    static func reduce(state: MeState, event: MeState.Event) -> MeState {
        switch event {
        case .onUpdateCurrentUser(let currentUser):
            return state.mutated {
                $0.currentUser = currentUser
                $0.nextMeQuery.userId = currentUser?.id ?? ""
                $0.nextMyMediaQuery.userId = currentUser?.id ?? ""
            }
        case .onTriggerReloadMe:
            return state.mutated {
                $0.meError = nil
                $0.triggerQueryMe = true
            }
        case .onGetMeSuccess(let data):
            return state.mutated {
                $0.me = data
                $0.meError = nil
                $0.triggerQueryMe = false
            }
        case .onGetMeError(let error):
            return state.mutated {
                $0.me = nil
                $0.meError = error
                $0.triggerQueryMe = false
            }
        case .onTriggerReload:
            return state.mutated {
                $0.nextMyMediaQuery.cursor = nil
                $0.myMediaItems = []
                $0.myMediaError = nil
                $0.triggerQueryMyMedia = true
            }
        case .onTriggerGetMore:
            guard state.shouldQueryMoreMyMedia else { return state }
            return state.mutated {
                $0.myMediaError = nil
                $0.triggerQueryMyMedia = true
            }
        case .onGetSuccess(let data):
            return state.mutated {
                $0.nextMyMediaQuery.cursor = data.cursor
                $0.myMediaItems += data.items.flatMap { $0 }
                $0.myMediaError = nil
                $0.triggerQueryMyMedia = false
            }
        case .onGetError(let error):
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
        case .onTriggerShowReputations:
            return state.mutated {
                $0.triggerShowReputations = true
            }
        case .onShowReputationsCompleted:
            return state.mutated {
                $0.triggerShowReputations = false
            }
        }
    }
}
