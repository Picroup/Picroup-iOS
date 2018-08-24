//
//  NotificationsStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

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
            sessionState?.currentUser?.notificationsCount.value = 0
            marked = id
            markError = nil
            triggerMarkQuery = false
        case .onMarkError(let error):
            marked = nil
            markError = error.localizedDescription
            triggerMarkQuery = false
            
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        case .onTriggerShowComments(let mediumId):
            routeState?.reduce(event: .onTriggerShowComments(mediumId), realm: realm)
        case .onTriggerShowUser(let userId):
            routeState?.reduce(event: .onTriggerShowUser(userId), realm: realm)
        }
    }
}
