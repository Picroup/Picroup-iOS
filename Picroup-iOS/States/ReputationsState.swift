//
//  ReputationsState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct ReputationsState: Mutabled {
    
    var currentUser: UserDetailFragment?
    
    var reputation: Int
    
    var next: MyReputationsQuery
    var items: [ReputationFragment]
    var error: Error?
    var trigger: Bool
    
    var nextMark: MarkReputationLinksAsViewedQuery
    var marked: MarkReputationLinksAsViewedQuery.Data.User.MarkReputationLinksAsViewed?
    var markError: Error?
    var markTrigger: Bool
}

extension ReputationsState {
    public var query: MyReputationsQuery? {
        if (currentUser == nil) { return nil }
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
    public var markQuery: MarkReputationLinksAsViewedQuery? {
        if (currentUser == nil) { return nil }
        return markTrigger && !items.isEmpty ? nextMark : nil
    }
}

extension ReputationsState {
    static func empty(reputation: Int) -> ReputationsState {
        return ReputationsState(
            currentUser: nil,
            reputation: reputation,
            next: MyReputationsQuery(userId: ""),
            items: [],
            error: nil,
            trigger: true,
            nextMark: MarkReputationLinksAsViewedQuery(userId: ""),
            marked: nil,
            markError: nil,
            markTrigger: true
        )
    }
}

extension ReputationsState: IsFeedbackState {
    enum Event {
        case onUpdateCurrentUser(UserDetailFragment?)
        case onTriggerReload
        case onTriggerGetMore
        case onGetSuccess(CursorReputationLinksFragment)
        case onGetError(Error)
        case onMarkSuccess(MarkReputationLinksAsViewedQuery.Data.User.MarkReputationLinksAsViewed)
        case onMarkError(Error)
    }
}

extension ReputationsState {
    
    static func reduce(state: ReputationsState, event: ReputationsState.Event) -> ReputationsState {
        switch event {
        case .onUpdateCurrentUser(let currentUser):
            return state.mutated {
                $0.currentUser = currentUser
                $0.next.userId = currentUser?.id ?? ""
                $0.nextMark.userId = currentUser?.id ?? ""
            }
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
                $0.items += data.items.flatMap { $0.fragments.reputationFragment }
                $0.error = nil
                $0.trigger = false
            }
        case .onGetError(let error):
            return state.mutated {
                $0.error = error
                $0.trigger = false
            }
        case .onMarkSuccess(let data):
            return state.mutated {
                $0.marked = data
                $0.markError = nil
                $0.markTrigger = false
            }
        case .onMarkError(let error):
            return state.mutated {
                $0.marked = nil
                $0.markError = error
                $0.markTrigger = false
            }
        }
    }
}
