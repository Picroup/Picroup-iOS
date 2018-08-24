//
//  CreateImageStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxAlamofire


final class CreateImageStateObject: PrimaryObject {
    typealias Query = (userId: String, mediaItems: [MediumItem], tags: [String]?)

    @objc dynamic var session: UserSessionObject?
    
    let mediaItemObjects = List<MediaItemObject>()
    let tagStates = List<TagStateObject>()
    let saveMediumStates = List<SaveMediumStateObject>()
    @objc dynamic var finished: Int = 0
    @objc dynamic var triggerSaveMediumQuery: Bool = false
    
    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?

    @objc dynamic var routeState: RouteStateObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension CreateImageStateObject {
    var saveQuery: Query? {
        guard let userId = session?.currentUserId else { return nil }
        return triggerSaveMediumQuery ? (userId: userId, mediaItems: mediaItemObjects.map { $0.mediaItem }, tags: selectedTags) : nil
    }
    private var selectedTags: [String]? {
        return tagStates.compactMap { $0.isSelected ? $0.tag : nil }
    }
    var shouldSaveMedium: Bool {
        return !triggerSaveMediumQuery
    }
    var allFinished: Bool { return finished == mediaItemObjects.count }
    var completed: Float {
        let count = saveMediumStates.count
        let allProgress = saveMediumStates.reduce(0) { $0 + ($1.progress?.completed ?? 0)
        }
        if count > 0 {
            return Float(allProgress) / Float(count)
        }
        else {
            return 0
        }
    }
}

extension CreateImageStateObject {
    
    static func create(mediaItems: [MediumItem]) -> (Realm) throws -> CreateImageStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "mediaItemObjects": mediaItems.map { ["_id": $0.id] },
                "tags": [],
                "saveMediumStates": mediaItems.map { ["_id": $0.id, "progress": [:]] },
                "finished": 0,
                "triggerSaveMediumQuery": false,
                "selectedTagHistory": ["_id": _id],
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            let result = try realm.update(CreateImageStateObject.self, value: value)
            try realm.write {
                result.resetTagStates(realm: realm)
            }
            return result
        }
    }
}

extension CreateImageStateObject {
    
    fileprivate func resetTagStates(realm: Realm) {
        let tags = selectedTagHistory?.getTags().toArray() ?? []
        let tagStates = tags.map { realm.create(TagStateObject.self, value: ["tag": $0]) }
        self.tagStates.removeAll()
        self.tagStates.append(objectsIn: tagStates)
    }
}

