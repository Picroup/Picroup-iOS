//
//  NotificationsState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/25.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class NotificationsStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var notifications: CursorNotificationsObject?
    @objc dynamic var notificationsError: String?
    @objc dynamic var triggerNotificationsQuery: Bool = false
    
    @objc dynamic var marked: String?
    @objc dynamic var markError: String?
    @objc dynamic var triggerMarkQuery: Bool = false
    
    @objc dynamic var routeState: RouteStateObject?

}

extension NotificationsStateObject {
    public var notificationsQuery: MyNotificationsQuery? {
        guard let userId = session?.currentUserId else { return nil }
        let next = MyNotificationsQuery(userId: userId, cursor: notifications?.cursor.value)
        return triggerNotificationsQuery ? next : nil
    }
    var shouldQueryMoreNotifications: Bool {
        return !triggerNotificationsQuery && hasMoreNotifications
    }
    var isNotificationsEmpty: Bool {
        guard let items = notifications?.items else { return false }
        return !triggerNotificationsQuery && notificationsError == nil && items.isEmpty
    }
    var hasMoreNotifications: Bool {
        return notifications?.cursor.value != nil
    }
    public var markQuery: MarkNotificationsAsViewedQuery? {
        guard let userId = session?.currentUserId else { return nil }
        let next = MarkNotificationsAsViewedQuery(userId: userId)
        return triggerMarkQuery && !isNotificationsEmpty ? next : nil
    }
}


extension NotificationsStateObject {
    
    static func create() -> (Realm) throws -> NotificationsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "notifications": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(NotificationsStateObject.self, value: value)
        }
    }
}
