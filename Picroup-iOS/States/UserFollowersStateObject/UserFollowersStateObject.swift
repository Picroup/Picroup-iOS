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

final class UserFollowersStateObject: PrimaryObject {
    
    @objc dynamic var sessionStateState: UserSessionStateObject?
    
    @objc dynamic var user: UserObject?
    
    @objc dynamic var userFollowers: CursorUsersObject?
    @objc dynamic var userFollowersError: String?
    @objc dynamic var triggerUserFollowersQuery: Bool = false
    
    @objc dynamic var followToUserId: String?
    @objc dynamic var followUserError: String?
    @objc dynamic var triggerFollowUserQuery: Bool = false
    
    @objc dynamic var unfollowToUserId: String?
    @objc dynamic var unfollowUserError: String?
    @objc dynamic var triggerUnfollowUserQuery: Bool = false
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
}

extension UserFollowersStateObject {
    var userId: String { return _id }
    var userFollowersQuery: UserFollowersQuery? {
        let (byUserId, withFollowed) = sessionStateState?.currentUserId == nil
            ? ("", false)
            : (sessionStateState!.currentUser!._id, true)
        let next = UserFollowersQuery(userId: userId, followedByUserId: byUserId, cursor: userFollowers?.cursor.value, withFollowed: withFollowed)
        return triggerUserFollowersQuery ? next : nil
    }
    var shouldQueryMoreUserFollowers: Bool {
        return !triggerUserFollowersQuery && hasMoreUserFollowers
    }
    var isFollowersEmpty: Bool {
        guard let items = userFollowers?.items else { return false }
        return !triggerUserFollowersQuery && userFollowersError == nil && items.isEmpty
    }
    var hasMoreUserFollowers: Bool {
        return userFollowers?.cursor.value != nil
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

extension UserFollowersStateObject {
    
    static func create(userId: String) -> (Realm) throws -> UserFollowersStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": userId,
                "sessionStateState": ["_id": _id],
                "user": ["_id": userId],
                "userFollowers": ["_id": PrimaryKey.userFollowersId(userId)],
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(UserFollowersStateObject.self, value: value)
        }
    }
}

