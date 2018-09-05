//
//  UserFollowingsStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class UserFollowingsStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var user: UserObject?
    
    @objc dynamic var userFollowingsQueryState: UserFollowingsQueryStateObject?
    @objc dynamic var followUserQueryState: FollowUserQueryStateObject?
    @objc dynamic var unfollowUserQueryState: UnfollowUserQueryStateObject?
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
}

extension UserFollowingsStateObject {
    var userId: String { return _id }
    var userFollowingsQuery: UserFollowingsQuery? {
        return userFollowingsQueryState?.query(currentUserId: sessionState?.currentUserId)
    }
    
    var followUserQuery: FollowUserMutation? {
        return followUserQueryState?.query(userId: sessionState?.currentUserId)
    }
    
    var unfollowUserQuery: UnfollowUserMutation? {
        return unfollowUserQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension UserFollowingsStateObject {
    
    static func create(userId: String) -> (Realm) throws -> UserFollowingsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": userId,
                "sessionState": UserSessionStateObject.createValues(),
                "user": ["_id": userId],
                "userFollowingsQueryState": UserFollowingsQueryStateObject.createValues(id: PrimaryKey.userFollowingsId(userId), userId: userId),
                "followUserQueryState": FollowUserQueryStateObject.createValues(),
                "unfollowUserQueryState": UnfollowUserQueryStateObject.createValues(),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(UserFollowingsStateObject.self, value: value)
        }
    }
}
