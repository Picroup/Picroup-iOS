//
//  ReputationsState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct ReputationsState: Mutabled {
    typealias Item = MyReputationsQuery.Data.User.ReputationLink.Item
    
    var reputation: Int
    
    var next: MyReputationsQuery
    var items: [Item]
    var error: Error?
    var trigger: Bool
}

extension ReputationsState {
    public var query: MyReputationsQuery? {
        return trigger ? next : nil
    }
    var shouldQueryMore: Bool {
        return !trigger && next.cursor != nil
    }
    var isItemsEmpty: Bool {
        return !trigger && error == nil && items.isEmpty
    }
    var hasMore: Bool {
        return next.cursor != nil
    }
}

extension ReputationsState {
    static func empty(userId: String, reputation: Int) -> ReputationsState {
        return ReputationsState(
            reputation: reputation,
            next: MyReputationsQuery(userId: userId),
            items: [],
            error: nil,
            trigger: true
        )
    }
}

extension ReputationsState: IsFeedbackState {
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetSuccess(MyReputationsQuery.Data.User.ReputationLink)
        case onGetError(Error)
    }
}

extension ReputationsState {
    
    static func reduce(state: ReputationsState, event: ReputationsState.Event) -> ReputationsState {
        switch event {
        case .onTriggerReload:
            return state.mutated {
                $0.next.cursor = nil
                $0.items = []
                $0.error = nil
                $0.trigger = true
            }
        case .onTriggerGetMore:
            guard state.shouldQueryMore else { return state }
            return state.mutated {
                $0.error = nil
                $0.trigger = true
            }
        case .onGetSuccess(let data):
            return state.mutated {
                $0.next.cursor = data.cursor
                $0.items += data.items.flatMap { $0 }
                $0.error = nil
                $0.trigger = false
            }
        case .onGetError(let error):
            return state.mutated {
                $0.error = error
                $0.trigger = false
            }
        }
    }
}
