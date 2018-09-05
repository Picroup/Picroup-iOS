//
//  ResetPasswordStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class ResetPasswordStateObject: VersionedPrimaryObject {
    
    @objc dynamic var resetPasswordParamState: ResetPasswordParamStateObject?
    @objc dynamic var passwordValidQueryState: PasswordValidQueryStateObject?
    @objc dynamic var resetPasswordQueryState: ResetPasswordQueryStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension ResetPasswordStateObject {
    var validPasswordQuery: String? {
        return passwordValidQueryState?.query(password: resetPasswordParamState?.password)
    }
    var isPasswordValid: Bool {
        return passwordValidQueryState?.success != nil
    }
    var resetPasswordQuery: ResetPasswordMutation? {
        return resetPasswordQueryState?.query(
            phoneNumber: resetPasswordParamState?.phoneNumber,
            password: resetPasswordParamState?.password,
            token: resetPasswordParamState?.token
        )
    }
    var username: String? {
        return resetPasswordQueryState?.success
    }
}

extension ResetPasswordStateObject {
    
    static func create() -> (Realm) throws -> ResetPasswordStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "resetPasswordParamState": ResetPasswordParamStateObject.createValues(),
                "passwordValidQueryState": PasswordValidQueryStateObject.createValues(id: "\(self).\(_id).passwordValidQueryState"),
                "resetPasswordQueryState": ResetPasswordQueryStateObject.createValues(id: "\(self).\(_id).resetPasswordQueryState"),
                "username": nil,
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ResetPasswordStateObject.self, value: value)
        }
    }
}


