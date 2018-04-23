//
//  MeState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct MeState: Mutabled {
    typealias Me = QueryState<UserQuery, UserQuery.Data.User>
    typealias Item = MyMediaQuery.Data.User.Medium.Item
    var me: Me
    
    var nextMyMediaQuery: MyMediaQuery
    var myMediaItems: [Item]
    var myMediaError: Error?
    var triggerQueryMyMedia: Bool
    
    var nextShowImageDetailIndex: Int?
}

extension MeState {
    var myMediaQuery: MyMediaQuery? {
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
}

extension MeState {
    static func empty(userId: String) -> MeState {
        return MeState(
            me: Me(
                next: UserQuery(userId: userId),
                trigger: true
            ),
            nextMyMediaQuery: MyMediaQuery(userId: userId),
            myMediaItems: [],
            myMediaError: nil,
            triggerQueryMyMedia: true,
            nextShowImageDetailIndex: nil
        )
    }
}

extension MeState: IsFeedbackState {
    
    enum Event {
        case me(Me.Event)
        case onTriggerReload
        case onTriggerGetMore
        case onGetSuccess(MyMediaQuery.Data.User.Medium)
        case onGetError(Error)
        
        case onTriggerShowImageDetail(Int)
        case onShowImageDetailCompleted
    }
}

extension MeState {
    static func reduce(state: MeState, event: MeState.Event) -> MeState {
        switch event {
        case .me(let event):
            return state.mutated {
                $0.me -= event
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
        }
    }
}
