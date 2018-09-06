//
//  UnblockUserQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/31.
//  Copyright © 2018年 luojie. All rights reserved.
//


import Foundation
import RealmSwift

final class UnblockUserQueryStateObject: PrimaryObject {
    
    @objc dynamic var unblockingUserId: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension UnblockUserQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(userId: String?) -> UnblockUserMutation? {
        guard let userId = userId,
            let unblockingUserId = unblockingUserId else { return nil }
        return trigger == true
            ? UnblockUserMutation(userId: userId, blockingUserId: unblockingUserId)
            : nil
    }
}

extension UnblockUserQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension UnblockUserQueryStateObject {
    
    enum Event {
        case onTriggerUnblockUser(String)
        case onSuccess(UnblockUserMutation.Data.UnblockUser)
        case onError(Error)
    }
}

extension UnblockUserQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerUnblockUser(let unblockingUserId):
            guard shouldQuery else { return }
            self.unblockingUserId = unblockingUserId
            error = nil
            trigger = true
        case .onSuccess(let data):
            let user = realm.create(UserObject.self, value: data.snapshot, update: true)
            user.blocked.value = false
            unblockingUserId = nil
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}


