//
//  FollowUserQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/30.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class FollowUserQueryStateObject: PrimaryObject {
    
    @objc dynamic var followToUserId: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension FollowUserQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(userId: String?) -> FollowUserMutation? {
        guard let userId = userId,
            let toUserId = followToUserId else { return nil }
        return trigger == true
            ? FollowUserMutation(userId: userId, toUserId: toUserId)
            : nil
    }
}

extension FollowUserQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension FollowUserQueryStateObject {
    
    enum Event {
        case onTriggerFollowUser(String)
        case onSuccess(FollowUserMutation.Data.FollowUser)
        case onError(Error)
    }
}

extension FollowUserQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerFollowUser(let toUserId):
            guard shouldQuery else { return }
            followToUserId = toUserId
            error = nil
            trigger = true
        case .onSuccess(let data):
            realm.create(UserObject.self, value: data.snapshot, update: true)
            followToUserId = nil
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}

