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

final class UpdateMediumTagsStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var medium: MediumObject?

    @objc dynamic var tagsState: UpdateImageTagsStateObject?
    @objc dynamic var addTagQueryState: MediumAddTagQueryStateObject?
    @objc dynamic var removeTagQueryState: MediumRemoveTagQueryStateObject?

    @objc dynamic var snackbar: SnackbarObject?
}

extension UpdateMediumTagsStateObject {
    var mediumId: String { return _id }
    var addTagQuery: MediumAddTagQuery? {
        return addTagQueryState?.query(mediumId: mediumId, currentUserId: sessionState?.currentUserId)
    }
    var removeTagQuery: MediumRemoveTagQuery? {
        return removeTagQueryState?.query(mediumId: mediumId, currentUserId: sessionState?.currentUserId)
    }
}

extension UpdateMediumTagsStateObject {
    
    static func create(mediumId: String) -> (Realm) throws -> UpdateMediumTagsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": mediumId,
                "sessionState": UserSessionStateObject.createValues(),
                "medium": ["_id": mediumId],
                "tagsState": UpdateImageTagsStateObject.createValues(id: _id),
                "addTagQueryState": MediumAddTagQueryStateObject.createValues(),
                "removeTagQueryState": MediumRemoveTagQueryStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            let result = try realm.update(UpdateMediumTagsStateObject.self, value: value)
            try realm.write {
                result.tagsState?.reduce(event: .resetTagStates(result.medium?.tags.toArray()), realm: realm)
            }
            return result
        }
    }
}

