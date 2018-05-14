//
//  UserSession.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class UserSessionObject: PrimaryObject {
    @objc dynamic var currentUser: UserObject?
}

extension UserSessionObject {
    var isLogin: Bool {
        return currentUser != nil
    }
}

class NotificationObject: PrimaryObject {
    @objc dynamic var userId: String?
    @objc dynamic var toUserId: String?
    @objc dynamic var mediumId: String?
    @objc dynamic var content: String?
    
    let createdAt = RealmOptional<Double>()
    let endedAt = RealmOptional<Double>()
    let viewed = RealmOptional<Bool>()
    
    @objc dynamic var user: UserObject?
    @objc dynamic var medium: MediumObject?
}

class CursorNotifications: Object {
    
    let cursor = RealmOptional<Double>()
    let items = List<NotificationObject>()
}

class NotificationsStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var notifications: CursorNotifications?
    @objc dynamic var notificationsError: String?
    @objc dynamic var triggerNotificationsQuery: Bool = false
}

extension NotificationsStateObject {
    public var notificationsQuery: MyNotificationsQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
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
//    public var markQuery: MarkNotificationsAsViewedQuery? {
//        if (currentUser == nil) { return nil }
//        return markTrigger && !items.isEmpty ? nextMark : nil
//    }
}

extension NotificationsStateObject {
    
    static func create(userId: String) -> (Realm) throws -> NotificationsStateObject {
        return { realm in
            let _id = Config.realmDefaultPrimaryKey
            let value: Any = [
                "_id": userId,
                "session": ["_id", _id],
                "notifications": ["_id": userId]
            ]
            return try realm.findOrCreate(NotificationsStateObject.self, forPrimaryKey: userId, value: value)
        }
    }
}

extension NotificationsStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetReloadData(CursorNotoficationsFragment)
        case onGetMoreData(CursorNotoficationsFragment)
        case onGetError(Error)
    }
}

extension NotificationsStateObject.Event {
    
    static func onGetData(isReload: Bool) -> (CursorNotoficationsFragment) -> NotificationsStateObject.Event {
        return { isReload ? .onGetReloadData($0) : .onGetMoreData($0) }
    }
}

extension NotificationsStateObject {
    
    func reduce(event: Event, realm: Realm) {
        print("NotificationsStateObject event", event)
        switch event {
        case .onTriggerReload:
            notifications?.cursor.value = nil
            notificationsError = nil
            triggerNotificationsQuery = true
        case .onTriggerGetMore:
            guard shouldQueryMoreNotifications else { return }
            notificationsError = nil
            triggerNotificationsQuery = true
        case .onGetReloadData(let data):
            notifications = realm.create(CursorNotifications.self, value: data.snapshot, update: true)
            notificationsError = nil
            triggerNotificationsQuery = false
        case .onGetMoreData(let data):
            let items = data.items.map { realm.create(NotificationObject.self, value: $0.snapshot, update: true) }
            notifications?.cursor.value = data.cursor
            notifications?.items.append(objectsIn: items)
            notificationsError = nil
            triggerNotificationsQuery = false
        case .onGetError(let error):
            notificationsError = error.localizedDescription
            triggerNotificationsQuery = false
        }
    }
}
