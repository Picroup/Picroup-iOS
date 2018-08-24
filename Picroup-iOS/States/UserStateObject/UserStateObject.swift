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
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var user: UserObject?
    @objc dynamic var userError: String?
    @objc dynamic var triggerUserQuery: Bool = false
    
    @objc dynamic var userMediaState: CursorMediaStateObject?
    
    @objc dynamic var followUserVersion: String?
    @objc dynamic var followUserError: String?
    @objc dynamic var triggerFollowUserQuery: Bool = false
    
    @objc dynamic var unfollowUserVersion: String?
    @objc dynamic var unfollowUserError: String?
    @objc dynamic var triggerUnfollowUserQuery: Bool = false
    
    @objc dynamic var blockUserVersion: String?
    @objc dynamic var blockUserError: String?
    @objc dynamic var triggerBlockUserQuery: Bool = false
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?

    @objc dynamic var routeState: RouteStateObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension UserStateObject {
    var userId: String { return _id }
    var userQuery: UserQuery? {
        let (byUserId, withFollowed) = session?.currentUserId == nil
            ? ("", false)
            : (session!.currentUser!._id, true)
        let next = UserQuery(userId: userId, followedByUserId: byUserId, withFollowed: withFollowed)
        return triggerUserQuery ? next : nil
    }
    var userMediaQuery: MyMediaQuery? {
        return userMediaState?.trigger == true
            ? MyMediaQuery(userId: userId, cursor: userMediaState?.cursorMedia?.cursor.value, queryUserId: session?.currentUserId)
            : nil
    }
    var shouldFollowUser: Bool {
        return user?.followed.value == false && !triggerFollowUserQuery
    }
    var followUserQuery: FollowUserMutation? {
        guard
            let userId = session?.currentUserId,
            let toUserId = user?._id else {
                return nil
        }
        return triggerFollowUserQuery ? FollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
    var shouldUnfollowUser: Bool {
        return user?.followed.value == true && !triggerUnfollowUserQuery
    }
    var unfollowUserQuery: UnfollowUserMutation? {
        guard
            let userId = session?.currentUserId,
            let toUserId = user?._id else {
                return nil
        }
        return triggerUnfollowUserQuery ? UnfollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
    var shouldBlockUser: Bool {
        return !triggerBlockUserQuery
    }
    var blockUserQuery: BlockUserMutation? {
        guard
            let userId = session?.currentUserId,
            let toUserId = user?._id else {
                return nil
        }
        return triggerBlockUserQuery
            ? BlockUserMutation(userId: userId, blockingUserId: toUserId)
            : nil
    }
}

extension UserStateObject {
    
    static func create(userId: String) -> (Realm) throws -> UserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": userId,
                "session": ["_id": _id],
                "user": ["_id": userId],
                "userMediaState": CursorMediaStateObject.createValues(id: PrimaryKey.userMediaId(userId)),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(UserStateObject.self, value: value)
        }
    }
}
