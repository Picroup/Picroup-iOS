//
//  BlockUserQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/31.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class BlockUserQueryStateObject: PrimaryObject {
    
    @objc dynamic var blockingUserId: String?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension BlockUserQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(userId: String?) -> BlockUserMutation? {
        guard let userId = userId,
            let blockingUserId = blockingUserId else { return nil }
        return trigger == true
            ? BlockUserMutation(userId: userId, blockingUserId: blockingUserId)
            : nil
    }
}

extension BlockUserQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}

extension BlockUserQueryStateObject {
    
    enum Event {
        case onTriggerBlockUser(String)
        case onSuccess(BlockUserMutation.Data.BlockUser)
        case onError(Error)
    }
}

extension BlockUserQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerBlockUser(let blockingUserId):
            guard shouldQuery else { return }
            self.blockingUserId = blockingUserId
            error = nil
            trigger = true
        case .onSuccess(let data):
            let user = realm.create(UserObject.self, value: data.snapshot, update: true)
            user.blocked.value = true
            blockingUserId = nil
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}

