//
//  CursorNotificationsStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class CursorNotificationsQueryStateObject: PrimaryObject {
    @objc dynamic var cursorNotifications: CursorNotificationsObject?
    @objc dynamic var error: String?
    @objc dynamic var isReload: Bool = false
    @objc dynamic var trigger: Bool = false
}

extension CursorNotificationsQueryStateObject: IsCursorItemsStateObject {
    var cursorItemsObject: CursorNotificationsObject? { return cursorNotifications }
}

extension CursorNotificationsQueryStateObject {
    
    func query(userId: String?) -> MyNotificationsQuery? {
        guard let userId = userId else { return nil }
        return trigger == true
            ? MyNotificationsQuery(userId: userId, cursor: cursorItemsObject?.cursor.value)
            : nil
    }
}

extension CursorNotificationsQueryStateObject {
    
    static func createValues(id: String) -> Any {
        return  [
            "_id": id,
            "cursorNotifications": ["_id": id],
        ]
    }
}

extension CursorNotificationsQueryStateObject {
    
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetData(CursorNotoficationsFragment)
        case onGetError(Error)
    }
}

extension CursorNotificationsQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReload:
            isReload = true
            cursorNotifications?.cursor.value = nil
            error = nil
            trigger = true
        case .onTriggerGetMore:
            guard shouldQueryMore else { return }
            isReload = false
            error = nil
            trigger = true
        case .onGetData(let data):
            if isReload {
                cursorNotifications = CursorNotificationsObject.create(from: data, id: _id)(realm)
                isReload = false
            } else {
                cursorNotifications?.merge(from: data)(realm)
            }
            error = nil
            trigger = false
        case .onGetError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
