//
//  UnfollowUserQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/30.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class UnfollowUserQueryStateObject: PrimaryObject {
    
    @objc dynamic var unfollowToUserId: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension UnfollowUserQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(userId: String?) -> UnfollowUserMutation? {
        guard let userId = userId,
            let toUserId = unfollowToUserId else { return nil }
        return trigger == true
            ? UnfollowUserMutation(userId: userId, toUserId: toUserId)
            : nil
    }
}

extension UnfollowUserQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension UnfollowUserQueryStateObject {
    
    enum Event {
        case onTriggerUnfollowUser(String)
        case onSuccess(UnfollowUserMutation.Data.UnfollowUser)
        case onError(Error)
    }
}

extension UnfollowUserQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerUnfollowUser(let toUserId):
            guard shouldQuery else { return }
            unfollowToUserId = toUserId
            error = nil
            trigger = true
        case .onSuccess(let data):
            realm.create(UserObject.self, value: data.snapshot, update: true)
            unfollowToUserId = nil
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}
