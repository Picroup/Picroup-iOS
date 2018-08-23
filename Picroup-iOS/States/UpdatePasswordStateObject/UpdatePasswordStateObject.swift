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
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var oldPassword: String = ""
    @objc dynamic var password: String = ""
    
    @objc dynamic var isOldPasswordValid: Bool = false
    @objc dynamic var isPasswordValid: Bool = false
    
    @objc dynamic var setPasswordError: String?
    @objc dynamic var triggerSetPasswordQuery: Bool = false
    
    @objc dynamic var popRoute: PopRouteObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension UpdatePasswordStateObject {
    var setPasswordQuery: UserSetPasswordQuery? {
        guard let userId = session?.currentUserId else { return nil }
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
                "session": ["_id": _id],
                "oldPassword": "",
                "password": "",
                "isOldPasswordValid": false,
                "isPasswordValid": false,
                "popRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(UpdatePasswordStateObject.self, value: value)
        }
    }
}


