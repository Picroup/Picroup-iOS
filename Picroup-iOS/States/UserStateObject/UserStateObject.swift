//
//  UserStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/18.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class UserStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var userQueryState: UserQueryStateObject?
    @objc dynamic var userMediaQueryState: UserMediaQueryStateObject?
    @objc dynamic var followUserQueryState: FollowUserQueryStateObject?
    @objc dynamic var unfollowUserQueryState: UnfollowUserQueryStateObject?
    @objc dynamic var blockUserQueryState: BlockUserQueryStateObject?
    @objc dynamic var starMediumQueryState: StarMediumQueryStateObject?
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    @objc dynamic var routeState: RouteStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension UserStateObject {
    var userId: String { return _id }
    var userQuery: UserQuery? {
        return userQueryState?.query(currentUserId: sessionState?.currentUserId)
    }
    var userMediaQuery: MyMediaQuery? {
        return userMediaQueryState?.query(userId: userId, currentUserId: sessionState?.currentUserId)
    }
    var followUserQuery: FollowUserMutation? {
        return followUserQueryState?.query(userId: sessionState?.currentUserId)
    }
    var unfollowUserQuery: UnfollowUserMutation? {
        return unfollowUserQueryState?.query(userId: sessionState?.currentUserId)
    }
    var blockUserQuery: BlockUserMutation? {
        return blockUserQueryState?.query(userId: sessionState?.currentUserId)
    }
    var starMediumQuery: StarMediumMutation? {
        return starMediumQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension UserStateObject {
    
    static func create(userId: String) -> (Realm) throws -> UserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": userId,
                "sessionState": UserSessionStateObject.createValues(),
                "userQueryState":  UserQueryStateObject.createValues(id: userId),
                "userMediaQueryState": UserMediaQueryStateObject.createValues(id: PrimaryKey.userMediaId(userId)),
                "followUserQueryState": FollowUserQueryStateObject.createValues(),
                "unfollowUserQueryState": UnfollowUserQueryStateObject.createValues(),
                "blockUserQueryState": BlockUserQueryStateObject.createValues(),
                "starMediumQueryState": StarMediumQueryStateObject.createValues(),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(UserStateObject.self, value: value)
        }
    }
}
