//
//  UpdateMediumTagsStateObject.swift
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
import RxAlamofire

final class UpdateMediumTagsStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    @objc dynamic var medium: MediumObject?

    let tagStates = List<TagStateObject>()
    
    @objc dynamic var selectedTagHistory: SelectedTagHistoryObject?
    
    @objc dynamic var addTag: String?
    @objc dynamic var addTagError: String?
    @objc dynamic var triggerAddTagQuery: Bool = false
    
    @objc dynamic var removeTag: String?
    @objc dynamic var removeTagError: String?
    @objc dynamic var triggerRemoveTagQuery: Bool = false

    @objc dynamic var snackbar: SnackbarObject?
}

extension UpdateMediumTagsStateObject {
    var mediumId: String { return _id }
    var addTagQuery: MediumAddTagQuery? {
        guard let tag = addTag, let byUserId = session?.currentUserId else { return nil }
        return triggerAddTagQuery ? MediumAddTagQuery(mediumId: mediumId, tag: tag, byUserId: byUserId) : nil
    }
    var removeTagQuery: MediumRemoveTagQuery? {
        guard let tag = removeTag, let byUserId = session?.currentUserId else { return nil }
        return triggerRemoveTagQuery ? MediumRemoveTagQuery(mediumId: mediumId, tag: tag, byUserId: byUserId) : nil
    }
}

extension UpdateMediumTagsStateObject {
    
    static func create(mediumId: String) -> (Realm) throws -> UpdateMediumTagsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": mediumId,
                "session": ["_id": _id],
                "medium": ["_id": mediumId],
                "selectedTagHistory": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            let result = try realm.update(UpdateMediumTagsStateObject.self, value: value)
            try realm.write {
                result.resetTagStates(realm: realm)
            }
            return result
        }
    }
}

extension UpdateMediumTagsStateObject {
    
    fileprivate func resetTagStates(realm: Realm) {
        let selectedTags = medium?.tags.toArray() ?? []
        let historyTags = selectedTagHistory?.getTags().toArray() ?? []
        let uncontainedHistoryTags = historyTags.filter { !selectedTags.contains($0) }
        let selectedTagStates = selectedTags.map { realm.create(TagStateObject.self, value: ["tag": $0, "isSelected": true]) }
        let historyTagStates = uncontainedHistoryTags.map { realm.create(TagStateObject.self, value: ["tag": $0, "isSelected": false]) }
        self.tagStates.removeAll()
        self.tagStates.append(objectsIn: selectedTagStates)
        self.tagStates.append(objectsIn: historyTagStates)
    }
}

