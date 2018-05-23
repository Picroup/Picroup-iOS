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
    
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
    @objc dynamic var imageCommetsRoute: ImageCommetsRouteObject?
    @objc dynamic var userRoute: UserRouteObject?
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
    public var markQuery: MarkNotificationsAsViewedQuery? {
        guard let userId = session?.currentUser?._id else { return nil }
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
                "imageDetialRoute": ["_id": _id],
                "imageCommetsRoute": ["_id": _id],
                "userRoute": ["_id": _id],
                ]
            return try realm.findOrCreate(NotificationsStateObject.self, forPrimaryKey: _id, value: value)
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
        case onMarkSuccess(String)
        case onMarkError(Error)
        
        case onTriggerShowImage(String)
        case onTriggerShowComments(String)
        case onTriggerShowUser(String)
    }
}

extension NotificationsStateObject.Event {
    
    static func onGetData(isReload: Bool) -> (CursorNotoficationsFragment) -> NotificationsStateObject.Event {
        return { isReload ? .onGetReloadData($0) : .onGetMoreData($0) }
    }
}

extension NotificationsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
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
            notifications = CursorNotificationsObject.create(from: data, id: PrimaryKey.default)(realm)
            notificationsError = nil
            triggerNotificationsQuery = false
            
            marked = nil
            markError = nil
            triggerMarkQuery = true
        case .onGetMoreData(let data):
            notifications?.merge(from: data)(realm)
            notificationsError = nil
            triggerNotificationsQuery = false
        case .onGetError(let error):
            notificationsError = error.localizedDescription
            triggerNotificationsQuery = false
            
        case .onMarkSuccess(let id):
            marked = id
            markError = nil
            triggerMarkQuery = false
        case .onMarkError(let error):
            marked = nil
            markError = error.localizedDescription
            triggerMarkQuery = false
            
        case .onTriggerShowImage(let mediumId):
            imageDetialRoute?.mediumId = mediumId
            imageDetialRoute?.version = UUID().uuidString
        case .onTriggerShowComments(let mediumId):
            imageCommetsRoute?.mediumId = mediumId
            imageCommetsRoute?.version = UUID().uuidString
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.version = UUID().uuidString
        }
    }
}

final class NotificationsStateStore {
    
    let states: Driver<NotificationsStateObject>
    private let _state: NotificationsStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try NotificationsStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: NotificationsStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: NotificationsStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func notifications() -> Driver<[NotificationObject]> {
        guard let items = _state.notifications?.items else { return .empty() }
        return Observable.collection(from: items)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}

