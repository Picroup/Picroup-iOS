//
//  UserBlockingsStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/8/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class UserBlockingsStateObject: PrimaryObject {
    
    @objc dynamic var sessionStateState: UserSessionStateObject?
    
    let userBlockings = List<UserObject>()
    @objc dynamic var userBlockingsError: String?
    @objc dynamic var triggerUserBlockingsQuery: Bool = false
    
    @objc dynamic var blockingUserId: String?
    @objc dynamic var blockUserError: String?
    @objc dynamic var triggerBlockUserQuery: Bool = false
    
    @objc dynamic var unblockingUserId: String?
    @objc dynamic var unblockUserError: String?
    @objc dynamic var triggerUnblockUserQuery: Bool = false
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
}

extension UserBlockingsStateObject {
    var userBlockingsQuery: UserBlockingUsersQuery? {
        guard let userId = sessionStateState?.currentUserId else { return nil }
        return triggerUserBlockingsQuery
            ? UserBlockingUsersQuery(userId: userId)
            : nil
    }
    var isBlockingsEmpty: Bool {
        return !triggerUserBlockingsQuery && userBlockingsError == nil && userBlockings.isEmpty
    }
    
    var shouldBlockUser: Bool {
        return !triggerBlockUserQuery
    }
    var blockUserQuery: BlockUserMutation? {
        guard let userId = sessionStateState?.currentUserId,
            let blockingUserId = blockingUserId else { return nil }
        return triggerBlockUserQuery
            ? BlockUserMutation(userId: userId, blockingUserId: blockingUserId)
            : nil
    }
    
    var shouldUnblockUser: Bool {
        return !triggerUnblockUserQuery
    }
    var unblockUserQuery: UnblockUserMutation? {
        guard let userId = sessionStateState?.currentUserId,
            let unblockingUserId = unblockingUserId else { return nil }
        return triggerUnblockUserQuery
            ? UnblockUserMutation(userId: userId, blockingUserId: unblockingUserId)
            : nil
    }
}

extension UserBlockingsStateObject {
    
    static func create() -> (Realm) throws -> UserBlockingsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionStateState": ["_id": _id],
                "userBlockings": [],
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(UserBlockingsStateObject.self, value: value)
        }
    }
}
