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

final class SearchUserStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var searchUserQueryState: SearchUserQueryStateObject?
    
    @objc dynamic var followUserQueryState: FollowUserQueryStateObject?
    @objc dynamic var unfollowUserQueryState: UnfollowUserQueryStateObject?
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    @objc dynamic var routeState: RouteStateObject?
}

extension SearchUserStateObject {
    var searchUserQuery: SearchUserQuery? {
        return searchUserQueryState?.query(followedByUserId: sessionState?.currentUserId)
    }
    
    var followUserQuery: FollowUserMutation? {
        return followUserQueryState?.query(userId: sessionState?.currentUserId)
    }
    
    var unfollowUserQuery: UnfollowUserMutation? {
        return unfollowUserQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension SearchUserStateObject {
    
    static func create() -> (Realm) throws -> SearchUserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "searchUserQueryState": SearchUserQueryStateObject.createValues(),
                "followUserQueryState": FollowUserQueryStateObject.createValues(),
                "unfollowUserQueryState": UnfollowUserQueryStateObject.createValues(),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(SearchUserStateObject.self, value: value)
        }
    }
}

