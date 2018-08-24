//
//  TagMediaStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class TagMediaStateObject: VersionedPrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var hotMediaState: CursorMediaStateObject?

    @objc dynamic var routeState: RouteStateObject?
}

extension TagMediaStateObject {
    var tag: String {
        return _id
    }
    var hotMediaQuery: HotMediaByTagsQuery? {
        return hotMediaState?.trigger == true
            ? HotMediaByTagsQuery(tags: [tag], queryUserId: session?.currentUserId)
            : nil
    }
}

extension TagMediaStateObject {
    
    static func create(tag: String) -> (Realm) throws -> TagMediaStateObject {
        let hotMediaId = PrimaryKey.hotMediaByTagId(tag)
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": tag,
                "session": ["_id": _id],
                "hotMediaState": CursorMediaStateObject.createValues(id: hotMediaId),
                "routeState": RouteStateObject.createValues(),
                ]
            let result = try realm.update(TagMediaStateObject.self, value: value)
            return result
        }
    }
}


