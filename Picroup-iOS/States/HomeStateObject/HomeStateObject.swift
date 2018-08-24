//
//  HomeStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class HomeStateObject: VersionedPrimaryObject {
        
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var myInterestedMediaState: CursorMediaStateObject?

    @objc dynamic var needUpdate: NeedUpdateStateObject?

    @objc dynamic var routeState: RouteStateObject?
}

extension HomeStateObject {
    var myInterestedMediaQuery: UserInterestedMediaQuery? {
        guard let userId = sessionState?.currentUserId else { return nil }
        return myInterestedMediaState?.trigger == true
            ? UserInterestedMediaQuery(userId: userId, cursor: myInterestedMediaState?.cursorMedia?.cursor.value)
            : nil
    }
}

extension HomeStateObject {
    
    static func create() -> (Realm) throws -> HomeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "myInterestedMediaState": CursorMediaStateObject.createValues(id: PrimaryKey.myInterestedMediaId),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            let state = try realm.update(HomeStateObject.self, value: value)
            return state
        }
    }
}
