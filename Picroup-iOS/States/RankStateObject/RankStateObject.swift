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

final class RankStateObject: PrimaryObject {
    
    @objc dynamic var version: String?

    @objc dynamic var session: UserSessionObject?
    
    let tagStates = List<TagStateObject>()
    
    @objc dynamic var hotMediaState: CursorMediaStateObject?

    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
    
    @objc dynamic var loginRoute: LoginRouteObject?
    @objc dynamic var imageDetialRoute: ImageDetialRouteObject?
}

extension RankStateObject {
    var hotMediaQuery: HotMediaByTagsQuery? {
        return hotMediaState?.trigger == true
            ? HotMediaByTagsQuery(tags: selectedTags, queryUserId: session?.currentUserId)
            : nil
    }
    private var selectedTags: [String]? {
        return tagStates.first(where: { $0.isSelected })
            .map { [$0.tag] }
    }
}

extension RankStateObject {
    
    static func create() -> (Realm) throws -> RankStateObject {
        let hotMediaId = PrimaryKey.hotMediaId
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "hotMediaState": CursorMediaStateObject.valuesBy(id: hotMediaId),
                "selectedTagHistory": ["_id": PrimaryKey.viewTagHistory],
                "loginRoute": ["_id": _id],
                "imageDetialRoute": ["_id": _id],
                ]
            let result = try realm.update(RankStateObject.self, value: value)
            try realm.write {
                result.resetTagStates(realm: realm)
            }
            return result
        }
    }
}

extension RankStateObject {
    
    fileprivate func resetTagStates(realm: Realm) {
        let tags = selectedTagHistory?.getTags().toArray() ?? []
        let tagStates = tags.map { realm.create(TagStateObject.self, value: ["tag": $0]) }
        tagStates.first?.isSelected = true
        self.tagStates.removeAll()
        self.tagStates.append(objectsIn: tagStates)
    }
}

