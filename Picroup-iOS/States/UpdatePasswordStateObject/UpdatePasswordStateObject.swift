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

final class UpdatePasswordStateObject: PrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
    
    @objc dynamic var oldPassword: String = ""
    @objc dynamic var password: String = ""
    
    @objc dynamic var isOldPasswordValid: Bool = false
    @objc dynamic var isPasswordValid: Bool = false
    
    @objc dynamic var setPasswordError: String?
    @objc dynamic var triggerSetPasswordQuery: Bool = false
    
    @objc dynamic var routeState: RouteStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension UpdatePasswordStateObject {
    var setPasswordQuery: UserSetPasswordQuery? {
        guard let userId = sessionState?.currentUserId else { return nil }
        let next = UserSetPasswordQuery(userId: userId, password: password, oldPassword: oldPassword)
        return triggerSetPasswordQuery ? next : nil
    }
    var shouldSetPassword: Bool {
        return isOldPasswordValid && isPasswordValid && !triggerSetPasswordQuery
    }
}

extension UpdatePasswordStateObject {
    
    static func create() -> (Realm) throws -> UpdatePasswordStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "sessionState": UserSessionStateObject.createValues(),
                "oldPassword": "",
                "password": "",
                "isOldPasswordValid": false,
                "isPasswordValid": false,
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(UpdatePasswordStateObject.self, value: value)
        }
    }
}


