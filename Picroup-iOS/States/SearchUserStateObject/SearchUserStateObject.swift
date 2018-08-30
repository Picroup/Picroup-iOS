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
    @objc dynamic var searchUserQueryStateObject: SearchUserQueryStateObject?
    
    @objc dynamic var followUserQueryStateObject: FollowUserQueryStateObject?
    @objc dynamic var unfollowUserQueryStateObject: UnfollowUserQueryStateObject?
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    @objc dynamic var routeState: RouteStateObject?
}

extension SearchUserStateObject {
    var searchUserQuery: SearchUserQuery? {
        return searchUserQueryStateObject?.query(followedByUserId: sessionState?.currentUserId)
    }
    
    var followUserQuery: FollowUserMutation? {
        return followUserQueryStateObject?.query(userId: sessionState?.currentUserId)
    }
    
    var unfollowUserQuery: UnfollowUserMutation? {
        return unfollowUserQueryStateObject?.query(userId: sessionState?.currentUserId)
    }
}

extension SearchUserStateObject {
    
    static func create() -> (Realm) throws -> SearchUserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "searchUserQueryStateObject": SearchUserQueryStateObject.createValues(),
                "followUserQuery": FollowUserQueryStateObject.createValues(),
                "unfollowUserQuery": UnfollowUserQueryStateObject.createValues(),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(SearchUserStateObject.self, value: value)
        }
    }
}

