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
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var hotMediaQueryState: TagMediaQueryStateObject?
    @objc dynamic var routeState: RouteStateObject?
}

extension TagMediaStateObject {
    var tag: String { return _id }
    var hotMediaQuery: HotMediaByTagsQuery? { return hotMediaQueryState?.query(tags: [tag], queryUserId: sessionState?.currentUserId) }
}

extension TagMediaStateObject {
    
    static func create(tag: String) -> (Realm) throws -> TagMediaStateObject {
        let tagMediaId = PrimaryKey.hotMediaByTagId(tag)
        return { realm in
            let value: Any = [
                "_id": tag,
                "sessionState": UserSessionStateObject.createValues(),
                "hotMediaQueryState": TagMediaQueryStateObject.createValues(id: tagMediaId),
                "routeState": RouteStateObject.createValues(),
                ]
            let result = try realm.update(TagMediaStateObject.self, value: value)
            return result
        }
    }
}


