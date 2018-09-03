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

final class CreateImageStateObject: VersionedPrimaryObject {

    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var tagsState: CreateImageTagsStateObject?
    @objc dynamic var saveImagesQueryState: SaveImagesQueryStateObject?
    
    @objc dynamic var needUpdate: NeedUpdateStateObject?
    @objc dynamic var routeState: RouteStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension CreateImageStateObject {
    var saveQuery: SaveImagesQueryStateObject.Query? {
        return saveImagesQueryState?.query(
            userId: sessionState?.currentUserId,
            tags: tagsState?.selectedTags
        )
    }
}

extension CreateImageStateObject {
    
    static func create(mediaItems: [MediumItem]) -> (Realm) throws -> CreateImageStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "tagsState": CreateImageTagsStateObject.createValues(id: _id),
                "saveImagesQueryState": SaveImagesQueryStateObject.createValues(id: _id, mediaItems: mediaItems),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            let result = try realm.update(CreateImageStateObject.self, value: value)
            try realm.write {
                result.tagsState?.reduce(event: .resetTagStates, realm: realm)
            }
            return result
        }
    }
}

