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
        case onGetData(CursorNotoficationsFragment)
        case onGetError(Error)
        
        case onMarkSuccess(String)
        case onMarkError(Error)
        
        case onTriggerShowImage(String)
        case onTriggerShowComments(String)
        case onTriggerShowUser(String)
    }
}

extension NotificationsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            notificationsQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerGetMore:
            notificationsQueryState?.reduce(event: .onTriggerGetMore, realm: realm)
        case .onGetData(let data):
            notificationsQueryState?.reduce(event: .onGetData(data), realm: realm)
            markNotificationsQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onGetError(let error):
            notificationsQueryState?.reduce(event: .onGetError(error), realm: realm)
            
        case .onMarkSuccess(let id):
            sessionState?.reduce(event: .onClearNotificationCount, realm: realm)
            markNotificationsQueryState?.reduce(event: .onSuccess(id), realm: realm)
        case .onMarkError(let error):
            markNotificationsQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerShowImage(let mediumId):
            routeState?.reduce(event: .onTriggerShowImage(mediumId), realm: realm)
        case .onTriggerShowComments(let mediumId):
            routeState?.reduce(event: .onTriggerShowComments(mediumId), realm: realm)
        case .onTriggerShowUser(let userId):
            routeState?.reduce(event: .onTriggerShowUser(userId), realm: realm)
        }
    }
}
