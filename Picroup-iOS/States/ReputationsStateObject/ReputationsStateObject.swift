//
//  ReputationsStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class ReputationsStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var reputationsQueryState: CursorReputationsQueryStateObject?
    @objc dynamic var markReputationsQueryState: MarkReputationsQueryStateObject?
    @objc dynamic var routeState: RouteStateObject?
}

extension ReputationsStateObject {
    public var reputationsQuery: MyReputationsQuery? {
        return reputationsQueryState?.query(userId: sessionState?.currentUserId)
    }
    public var markQuery: MarkReputationLinksAsViewedQuery? {
        return markReputationsQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension ReputationsStateObject {
    
    static func create() -> (Realm) throws -> ReputationsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "reputationsQueryState": CursorReputationsQueryStateObject.createValues(id: _id),
                "markReputationsQueryState": MarkReputationsQueryStateObject.createValues(),
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(ReputationsStateObject.self, value: value)
        }
    }
}

