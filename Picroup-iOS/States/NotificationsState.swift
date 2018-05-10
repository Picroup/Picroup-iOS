//
//  NotificationsState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/25.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct NotificationsState: Mutabled {
    typealias Item = MyNotificationsQuery.Data.User.Notification.Item
    
    var currentUser: UserDetailFragment?
    
    var next: MyNotificationsQuery
    var items: [Item]
    var error: Error?
    var trigger: Bool
    
    var nextMark: MarkNotificationsAsViewedQuery
    var marked: MarkNotificationsAsViewedQuery.Data.User.MarkNotificationsAsViewed?
    var markError: Error?
    var markTrigger: Bool
}

extension NotificationsState {
    public var query: MyNotificationsQuery? {
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
    public var markQuery: MarkNotificationsAsViewedQuery? {
        if (currentUser == nil) { return nil }
        return markTrigger && !items.isEmpty ? nextMark : nil
    }
}

extension NotificationsState {
    static func empty() -> NotificationsState {
        return NotificationsState(
            currentUser: nil,
            next: MyNotificationsQuery(userId: ""),
            items: [],
            error: nil,
            trigger: true,
            nextMark: MarkNotificationsAsViewedQuery(userId: ""),
            marked: nil,
            markError: nil,
            markTrigger: true
        )
    }
}

extension NotificationsState: IsFeedbackState {
    
    enum Event {
        case onUpdateCurrentUser(UserDetailFragment?)
        case onTriggerReload
        case onTriggerGetMore
        case onGetSuccess(MyNotificationsQuery.Data.User.Notification)
        case onGetError(Error)
        case onMarkSuccess(MarkNotificationsAsViewedQuery.Data.User.MarkNotificationsAsViewed)
        case onMarkError(Error)
    }
}

extension NotificationsState {
    
    static func reduce(state: NotificationsState, event: NotificationsState.Event) -> NotificationsState {
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
                $0.items += data.items.flatMap { $0 }
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
