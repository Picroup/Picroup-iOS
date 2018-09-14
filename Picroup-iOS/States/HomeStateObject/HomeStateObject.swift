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
    @objc dynamic var myInterestedMediaState: CursorMediaQueryStateObject?
    @objc dynamic var starMediumQueryState: StarMediumQueryStateObject?
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    @objc dynamic var routeState: RouteStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension HomeStateObject {
    var myInterestedMediaQuery: UserInterestedMediaQuery? {
        guard let userId = sessionState?.currentUserId else { return nil }
        return myInterestedMediaState?.trigger == true
            ? UserInterestedMediaQuery(userId: userId, cursor: myInterestedMediaState?.cursorMedia?.cursor.value, withStared: true)
            : nil
    }
    var starMediumQuery: StarMediumMutation? {
        return starMediumQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension HomeStateObject {
    
    static func create() -> (Realm) throws -> HomeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "myInterestedMediaState": CursorMediaQueryStateObject.createValues(id: PrimaryKey.myInterestedMediaId),
                "starMediumQueryState": StarMediumQueryStateObject.createValues(),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(HomeStateObject.self, value: value)
        }
    }
}
