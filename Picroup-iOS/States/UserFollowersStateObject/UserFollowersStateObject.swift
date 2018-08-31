//
//  UserFollowersStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class UserFollowersStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var user: UserObject?
    
    @objc dynamic var userFollowersQueryState: UserFollowersQueryStateObject?
    @objc dynamic var followUserQueryState: FollowUserQueryStateObject?
    @objc dynamic var unfollowUserQueryState: UnfollowUserQueryStateObject?
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
}

extension UserFollowersStateObject {
    var userId: String { return _id }
    var userFollowersQuery: UserFollowersQuery? {
        return userFollowersQueryState?.query(currentUserId: sessionState?.currentUserId)
    }
    
    var followUserQuery: FollowUserMutation? {
        return followUserQueryState?.query(userId: sessionState?.currentUserId)
    }
    
    var unfollowUserQuery: UnfollowUserMutation? {
        return unfollowUserQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension UserFollowersStateObject {
    
    static func create(userId: String) -> (Realm) throws -> UserFollowersStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": userId,
                "sessionState": UserSessionStateObject.createValues(),
                "user": ["_id": userId],
                "userFollowersQueryState": UserFollowersQueryStateObject.createValues(id: PrimaryKey.userFollowersId(userId), userId: userId),
                "followUserQueryState": FollowUserQueryStateObject.createValues(),
                "unfollowUserQueryState": UnfollowUserQueryStateObject.createValues(),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(UserFollowersStateObject.self, value: value)
        }
    }
}

