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

final class UserFollowingsStateObject: PrimaryObject {
    
    @objc dynamic var sessionStateState: UserSessionStateObject?
    
    @objc dynamic var user: UserObject?
    
    @objc dynamic var userFollowings: CursorUsersObject?
    @objc dynamic var userFollowingsError: String?
    @objc dynamic var triggerUserFollowingsQuery: Bool = false
    
    @objc dynamic var followToUserId: String?
    @objc dynamic var followUserError: String?
    @objc dynamic var triggerFollowUserQuery: Bool = false
    
    @objc dynamic var unfollowToUserId: String?
    @objc dynamic var unfollowUserError: String?
    @objc dynamic var triggerUnfollowUserQuery: Bool = false
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
}

extension UserFollowingsStateObject {
    var userId: String { return _id }
    var userFollowingsQuery: UserFollowingsQuery? {
        let (byUserId, withFollowed) = sessionStateState?.currentUserId == nil
            ? ("", false)
            : (sessionStateState!.currentUser!._id, true)
        let next = UserFollowingsQuery(userId: userId, followedByUserId: byUserId, cursor: userFollowings?.cursor.value, withFollowed: withFollowed)
        return triggerUserFollowingsQuery ? next : nil
    }
    var shouldQueryMoreUserFollowings: Bool {
        return !triggerUserFollowingsQuery && hasMoreUserFollowings
    }
    var isFollowingsEmpty: Bool {
        guard let items = userFollowings?.items else { return false }
        return !triggerUserFollowingsQuery && userFollowingsError == nil && items.isEmpty
    }
    var hasMoreUserFollowings: Bool {
        return userFollowings?.cursor.value != nil
    }
    
    var shouldFollowUser: Bool {
        return !triggerFollowUserQuery
    }
    var followUserQuery: FollowUserMutation? {
        guard
            let userId = sessionStateState?.currentUserId,
            let toUserId = followToUserId else {
                return nil
        }
        return triggerFollowUserQuery ? FollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
    
    var shouldUnfollowUser: Bool {
        return !triggerUnfollowUserQuery
    }
    var unfollowUserQuery: UnfollowUserMutation? {
        guard
            let userId = sessionStateState?.currentUserId,
            let toUserId = unfollowToUserId else {
                return nil
        }
        return triggerUnfollowUserQuery ? UnfollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
}

extension UserFollowingsStateObject {
    
    static func create(userId: String) -> (Realm) throws -> UserFollowingsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": userId,
                "sessionStateState": ["_id": _id],
                "user": ["_id": userId],
                "userFollowings": ["_id": PrimaryKey.userFollowingsId(userId)],
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(UserFollowingsStateObject.self, value: value)
        }
    }
}
