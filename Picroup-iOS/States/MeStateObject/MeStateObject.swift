//
//  MeStateObject.swift
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

final class MeStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionStateState: UserSessionStateObject?
    
    @objc dynamic var selectedTabIndex: Int = 0
    
    @objc dynamic var myMediaState: CursorMediaStateObject?
    
    @objc dynamic var myStaredMediaState: CursorMediaStateObject?

    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
}

extension MeStateObject {
    
    enum Tab: Int {
        case myMedia
        case myStaredMedia
    }
}

extension MeStateObject {
    var myMediaQuery: MyMediaQuery? {
        guard let userId = sessionStateState?.currentUserId else { return nil }
        return myMediaState?.trigger == true
            ? MyMediaQuery(userId: userId, cursor: myMediaState?.cursorMedia?.cursor.value, queryUserId: userId)
            : nil
    }
    var myStaredMediaQuery: MyStaredMediaQuery? {
        guard let userId = sessionStateState?.currentUserId else { return nil }
        return myStaredMediaState?.trigger == true
            ? MyStaredMediaQuery(userId: userId, cursor: myStaredMediaState?.cursorMedia?.cursor.value)
            : nil
    }
}

extension MeStateObject {
    
    static func create() -> (Realm) throws -> MeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionStateState": ["_id": _id],
                "myMediaState": CursorMediaStateObject.createValues(id: PrimaryKey.myMediaId),
                "myStaredMediaState":  CursorMediaStateObject.createValues(id: PrimaryKey.myStaredMediaId),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(MeStateObject.self, value: value)
        }
    }
}

