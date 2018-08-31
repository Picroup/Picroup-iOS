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

final class UserBlockingsStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var userBlockingUsersQueryState: UserBlockingUsersQueryStateObject?
    @objc dynamic var blockUserQueryState: BlockUserQueryStateObject?
    @objc dynamic var unblockUserQueryState: UnblockUserQueryStateObject?
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    @objc dynamic var routeState: RouteStateObject?
}

extension UserBlockingsStateObject {
    var userBlockingsQuery: UserBlockingUsersQuery? {
        return userBlockingUsersQueryState?.query(userId: sessionState?.currentUserId)
    }
    
    var blockUserQuery: BlockUserMutation? {
        return blockUserQueryState?.query(userId: sessionState?.currentUserId)
    }
    
    var unblockUserQuery: UnblockUserMutation? {
        return unblockUserQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension UserBlockingsStateObject {
    
    static func create() -> (Realm) throws -> UserBlockingsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "userBlockingUsersQueryState": UserBlockingUsersQueryStateObject.createValues(id: _id),
                "blockUserQueryState": BlockUserQueryStateObject.createValues(),
                "unblockUserQueryState": UnblockUserQueryStateObject.createValues(),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(UserBlockingsStateObject.self, value: value)
        }
    }
}
