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

final class ReputationsStateObject: PrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var reputations: CursorReputationsObject?
    @objc dynamic var reputationsError: String?
    @objc dynamic var triggerReputationsQuery: Bool = false
    
    @objc dynamic var marked: String?
    @objc dynamic var markError: String?
    @objc dynamic var triggerMarkQuery: Bool = false
    
    @objc dynamic var routeState: RouteStateObject?

}

extension ReputationsStateObject {
    public var reputationsQuery: MyReputationsQuery? {
        guard let userId = sessionState?.currentUserId else { return nil }
        let next = MyReputationsQuery(userId: userId, cursor: reputations?.cursor.value)
        return triggerReputationsQuery ? next : nil
    }
    var shouldQueryMoreReputations: Bool {
        return !triggerReputationsQuery && hasMoreReputations
    }
    var isReputationsEmpty: Bool {
        guard let items = reputations?.items else { return false }
        return !triggerReputationsQuery && reputationsError == nil && items.isEmpty
    }
    var hasMoreReputations: Bool {
        return reputations?.cursor.value != nil
    }
    public var markQuery: MarkReputationLinksAsViewedQuery? {
        guard let userId = sessionState?.currentUserId else { return nil }
        let next = MarkReputationLinksAsViewedQuery(userId: userId)
        return triggerMarkQuery && !isReputationsEmpty ? next : nil
    }
}


extension ReputationsStateObject {
    
    static func create() -> (Realm) throws -> ReputationsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "reputations": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(ReputationsStateObject.self, value: value)
        }
    }
}

