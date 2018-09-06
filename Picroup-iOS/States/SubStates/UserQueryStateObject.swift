//
//  UserQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/31.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

class UserQueryStateObject: PrimaryObject {
    @objc dynamic var user: UserObject?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension UserQueryStateObject {
    var userId: String { return _id }
    func query(currentUserId: String?) -> UserQuery? {
        let (byUserId, withFollowed) = currentUserId == nil
            ? ("", false)
            : (currentUserId!, true)
        return trigger
            ? UserQuery(userId: userId, followedByUserId: byUserId, withFollowed: withFollowed)
            : nil
    }
}

extension UserQueryStateObject {
    static func createValues(id: String) -> Any {
        return  [
            "_id": id,
            "user": ["_id": id],
        ]
    }
}

extension UserQueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess(UserQuery.Data.User)
        case onError(Error)
    }
}

extension UserQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            error = nil
            trigger = true
        case .onSuccess(let data):
            user = realm.create(UserObject.self, value: data.snapshot, update: true)
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}

