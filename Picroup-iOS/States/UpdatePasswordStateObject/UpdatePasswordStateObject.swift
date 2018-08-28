//
//  UpdatePasswordStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/7.
//  Copyright © 2018年 luojie. All rights reserved.
//


import RealmSwift
import RxSwift
import RxCocoa

final class UpdatePasswordStateObject: VersionedPrimaryObject {
    
    @objc dynamic var userSetPasswordQueryState: UserSetPasswordQueryStateObject?
    @objc dynamic var routeState: RouteStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension UpdatePasswordStateObject {
    var setPasswordQuery: UserSetPasswordQuery? { return userSetPasswordQueryState?.query }
    var shouldSetPassword: Bool { return userSetPasswordQueryState?.shouldSetPassword ?? false }
}

extension UpdatePasswordStateObject {
    
    static func create() -> (Realm) throws -> UpdatePasswordStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "userSetPasswordQueryState": UserSetPasswordQueryStateObject.createValues(),
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(UpdatePasswordStateObject.self, value: value)
        }
    }
}


