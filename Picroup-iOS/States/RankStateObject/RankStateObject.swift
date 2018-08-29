//
//  RankStateService.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class RankStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var hotMediaTagsState: HotMediaTagsStateObject?
    @objc dynamic var hotMediaQueryState: TagMediaQueryStateObject?
    @objc dynamic var routeState: RouteStateObject?

}

extension RankStateObject {
    var hotMediaQuery: HotMediaByTagsQuery? { return hotMediaQueryState?.query(tags: hotMediaTagsState?.selectedTags, queryUserId: sessionState?.currentUserId) }
}

extension RankStateObject {
    
    static func create() -> (Realm) throws -> RankStateObject {
        let hotMediaId = PrimaryKey.hotMediaId
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "hotMediaTagsState": HotMediaTagsStateObject.createValues(),
                "hotMediaQueryState": TagMediaQueryStateObject.createValues(id: hotMediaId),
                "routeState": RouteStateObject.createValues(),
                ]
            let result = try realm.update(RankStateObject.self, value: value)
            try realm.write {
                result.hotMediaTagsState?.reduce(event: .resetTagStates, realm: realm)
            }
            return result
        }
    }
}


