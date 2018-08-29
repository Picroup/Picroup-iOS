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

final class NotificationsStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var notificationsQueryState: CursorNotificationsQueryStateObject?
    @objc dynamic var markNotificationsQueryState: MarkNotificationsQueryStateObject?

//    @objc dynamic var marked: String?
//    @objc dynamic var markError: String?
//    @objc dynamic var triggerMarkQuery: Bool = false
    
    @objc dynamic var routeState: RouteStateObject?

}

extension NotificationsStateObject {
    public var notificationsQuery: MyNotificationsQuery? {
        return notificationsQueryState?.query(userId: sessionState?.currentUserId)
    }
    public var markQuery: MarkNotificationsAsViewedQuery? {
        return markNotificationsQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension NotificationsStateObject {
    
    static func create() -> (Realm) throws -> NotificationsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "notificationsQueryState": CursorNotificationsQueryStateObject.createValues(id: _id),
                "markNotificationsQueryState": MarkNotificationsQueryStateObject.createValues(),
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(NotificationsStateObject.self, value: value)
        }
    }
}
