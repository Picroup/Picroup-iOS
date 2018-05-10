//
//  MeState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct MeState: Mutabled {
    
    var currentUser: UserDetailFragment?
    
    var nextMeQuery: UserQuery
    var me: UserDetailFragment?
    var meError: Error?
    var triggerQueryMe: Bool
    
    var selectedTab: Tab
    
    var nextMyMediaQuery: MyMediaQuery
    var myMediaItems: [MediumFragment]
    var myMediaError: Error?
    var triggerQueryMyMedia: Bool
    
    var nextMyStaredMediaQuery: MyStaredMediaQuery
    var myStaredMediaItems: [MediumFragment]
    var myStaredMediaError: Error?
    var triggerQueryMyStaredMedia: Bool
    
    var nextShowImageDetailIndex: Int?
    
    var triggerShowReputations: Bool
}

extension MeState {

    enum Tab: Int {
        case myMedia
        case myStaredMedia
    }
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
    var isMyMediaItemsEmpty: Bool {
        return !triggerQueryMyMedia && myMediaError == nil && myMediaItems.isEmpty
    }
    var hasMoreMyMedia: Bool {
        return nextMyMediaQuery.cursor != nil
    }
    
    var myStaredMediaQuery: MyStaredMediaQuery? {
        if (currentUser == nil) { return nil }
        return triggerQueryMyStaredMedia ? nextMyStaredMediaQuery : nil
    }
    var shouldQueryMoreMyStaredMedia: Bool {
        return !triggerQueryMyStaredMedia && nextMyStaredMediaQuery.cursor != nil
    }
    var isMyStaredMediaItemsEmpty: Bool {
        return !triggerQueryMyStaredMedia && myStaredMediaError == nil && myStaredMediaItems.isEmpty
    }
    var hasMoreMStaredyMedia: Bool {
        return nextMyStaredMediaQuery.cursor != nil
    }
    
    var showImageDetailQuery: MediumFragment? {
        guard let index = nextShowImageDetailIndex else { return nil }
        return selectedTab == .myMedia ? myMediaItems[index] : myStaredMediaItems[index]
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
            selectedTab: .myMedia,
            nextMyMediaQuery: MyMediaQuery(userId: ""),
            myMediaItems: [],
            myMediaError: nil,
            triggerQueryMyMedia: true,
            
            nextMyStaredMediaQuery: MyStaredMediaQuery(userId: ""),
            myStaredMediaItems: [],
            myStaredMediaError: nil,
            triggerQueryMyStaredMedia: true,
            
            nextShowImageDetailIndex: nil,
            triggerShowReputations: false
        )
    }
}

extension MeState: IsFeedbackState {
    
    enum Event {
        case onUpdateCurrentUser(UserDetailFragment?)
        case onTriggerReloadMe
        case onGetMeSuccess(UserDetailFragment)
        case onGetMeError(Error)
        
        case onChangeSelectedTab(Tab)
        
        case onTriggerReloadMyMedia
        case onTriggerGetMoreMyMedia
        case onGetMyMediaSuccess(CursorMediaFragment)
        case onGetMyMediaError(Error)
        
        case onTriggerReloadMyStaredMedia
        case onTriggerGetMoreMyStaredMedia
        case onGetMyStaredMediaSuccess(CursorMediaFragment)
        case onGetMyStaredMediaError(Error)
        
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
                $0.nextMyStaredMediaQuery.userId = currentUser?.id ?? ""
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
            
        case .onChangeSelectedTab(let tab):
            return state.mutated {
                $0.selectedTab = tab
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
                $0.myMediaItems += data.items.flatMap { $0?.fragments.mediumFragment }
                $0.myMediaError = nil
                $0.triggerQueryMyMedia = false
            }
        case .onGetMyMediaError(let error):
            return state.mutated {
                $0.myMediaError = error
                $0.triggerQueryMyMedia = false
            }
            
        case .onTriggerReloadMyStaredMedia:
            return state.mutated {
                $0.nextMyStaredMediaQuery.cursor = nil
                $0.myStaredMediaItems = []
                $0.myStaredMediaError = nil
                $0.triggerQueryMyStaredMedia = true
            }
        case .onTriggerGetMoreMyStaredMedia:
            guard state.shouldQueryMoreMyStaredMedia else { return state }
            return state.mutated {
                $0.myStaredMediaError = nil
                $0.triggerQueryMyStaredMedia = true
            }
        case .onGetMyStaredMediaSuccess(let data):
            return state.mutated {
                $0.nextMyStaredMediaQuery.cursor = data.cursor
                $0.myStaredMediaItems += data.items.flatMap { $0?.fragments.mediumFragment }
                $0.myStaredMediaError = nil
                $0.triggerQueryMyStaredMedia = false
            }
        case .onGetMyStaredMediaError(let error):
            return state.mutated {
                $0.myStaredMediaError = error
                $0.triggerQueryMyStaredMedia = false
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
