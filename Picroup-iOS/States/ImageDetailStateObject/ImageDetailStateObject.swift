//
//  ImageDetailStateObject.swift
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

final class ImageDetailStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var isMediumDeleted: Bool = false

    @objc dynamic var mediumQueryState: MediumQueryStateObject?
    @objc dynamic var starMediumQueryState: StarMediumQueryStateObject?
    @objc dynamic var deleteMediumQueryState: DeleteMediumQueryStateObject?
    @objc dynamic var blockMediumQueryState: BlockMediumQueryStateObject?
    @objc dynamic var shareMediumQueryState: ShareMediumQueryStateObject?

    @objc dynamic var needUpdate: NeedUpdateStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension ImageDetailStateObject {
    var mediumId: String { return _id }
    var mediumQuery: MediumQuery? {
        return mediumQueryState?.query(currentUserId: sessionState?.currentUserId)
    }
    var starMediumQuery: StarMediumMutation? {
        return starMediumQueryState?.query(userId: sessionState?.currentUserId)
    }
    var deleteMediumQuery: DeleteMediumMutation? {
        return deleteMediumQueryState?.query(mediumId: mediumId)
    }
    var blockUserQuery: BlockMediumMutation? {
        return blockMediumQueryState?.query(userId: sessionState?.currentUserId, mediumId: mediumId)
    }
    var shareMediumQuery: ShareMediumQueryStateObject.Query? {
        return shareMediumQueryState?.query(medium: mediumQueryState?.medium)
    }
}

extension ImageDetailStateObject {
    
    static func create(mediumId: String) -> (Realm) throws -> ImageDetailStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": mediumId,
                "sessionState": UserSessionStateObject.createValues(),
                "mediumQueryState": MediumQueryStateObject.createValues(mediumId: mediumId),
                "starMediumQueryState": StarMediumQueryStateObject.createValues(),
                "deleteMediumQueryState": DeleteMediumQueryStateObject.createValues(id: mediumId),
                "blockMediumQueryState": BlockMediumQueryStateObject.createValues(id: mediumId),
                "shareMediumQueryState": ShareMediumQueryStateObject.createValues(id: mediumId),
                "needUpdate": ["_id": _id],
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ImageDetailStateObject.self, value: value)
        }
    }
}

