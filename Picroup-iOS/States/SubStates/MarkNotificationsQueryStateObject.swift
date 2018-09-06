//
//  MarkNotificationsQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class MarkNotificationsQueryStateObject: PrimaryObject {
    
    @objc dynamic var success: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension MarkNotificationsQueryStateObject {
    
    func query(userId: String?) -> MarkNotificationsAsViewedQuery? {
        guard let userId = userId else { return nil }
        return trigger == true
            ? MarkNotificationsAsViewedQuery(userId: userId)
            : nil
    }
}

extension MarkNotificationsQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension MarkNotificationsQueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess(String)
        case onError(Error)
    }
}

extension MarkNotificationsQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            success = nil
            error = nil
            trigger = true
        case .onSuccess(let id):
            success = id
            error = nil
            trigger = false
        case .onError(let error):
            success = nil
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
