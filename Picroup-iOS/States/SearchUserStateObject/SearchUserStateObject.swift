//
//  SearchUserStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class SearchUserStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var searchText: String = ""
    @objc dynamic var user: UserObject?
    @objc dynamic var searchError: String?
    @objc dynamic var triggerSearchUserQuery: Bool = false
    
    @objc dynamic var followToUserId: String?
    @objc dynamic var followUserError: String?
    @objc dynamic var triggerFollowUserQuery: Bool = false
    
    @objc dynamic var unfollowToUserId: String?
    @objc dynamic var unfollowUserError: String?
    @objc dynamic var triggerUnfollowUserQuery: Bool = false
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
}

extension SearchUserStateObject {
    var searchUserQuery: SearchUserQuery? {
        guard let byUserId = session?.currentUserId, !searchText.isEmpty else { return nil }
        let next = SearchUserQuery(username: searchText, followedByUserId: byUserId)
        return triggerSearchUserQuery ? next : nil
    }
    var userNotfound: Bool {
        return !searchText.isEmpty
            && !triggerSearchUserQuery
            && searchError == nil
            && user == nil
    }
    
    var shouldFollowUser: Bool {
        return !triggerFollowUserQuery
    }
    var followUserQuery: FollowUserMutation? {
        guard
            let userId = session?.currentUserId,
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
            let userId = session?.currentUserId,
            let toUserId = unfollowToUserId else {
                return nil
        }
        return triggerUnfollowUserQuery ? UnfollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
}

extension SearchUserQuery: Equatable {
    public static func ==(lhs: SearchUserQuery, rhs: SearchUserQuery) -> Bool {
        return lhs.username == rhs.username
            && lhs.followedByUserId == rhs.followedByUserId
    }
}

extension SearchUserStateObject {
    
    static func create() -> (Realm) throws -> SearchUserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(SearchUserStateObject.self, value: value)
        }
    }
}

