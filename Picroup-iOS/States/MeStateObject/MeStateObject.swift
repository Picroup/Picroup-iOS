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
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var tabState: MeTabStateObject?
    @objc dynamic var myMediaQueryState: MyMediaQueryStateObject?
    @objc dynamic var myStaredMediaQueryState: MyStaredMediaQueryStateObject?
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    @objc dynamic var routeState: RouteStateObject?
}

extension MeStateObject {
    var myMediaQuery: MyMediaQuery? {
        return myMediaQueryState?.query(userId: sessionState?.currentUserId)
    }
    var myStaredMediaQuery: MyStaredMediaQuery? {
        return myStaredMediaQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension MeStateObject {
    
    static func create() -> (Realm) throws -> MeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "tabState": MeTabStateObject.createValues(id: _id),
                "myMediaQueryState": CursorMediaQueryStateObject.createValues(id: PrimaryKey.myMediaId),
                "myStaredMediaQueryState":  CursorMediaQueryStateObject.createValues(id: PrimaryKey.myStaredMediaId),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                ]
            return try realm.update(MeStateObject.self, value: value)
        }
    }
}

