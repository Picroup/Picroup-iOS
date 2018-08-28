//
//  LoginStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


final class LoginStateObject: VersionedPrimaryObject {
    
    @objc dynamic var loginQueryState: LoginQueryStateObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension LoginStateObject {
    var loginQuery: LoginQuery? { return loginQueryState?.query }
    var isUsernameValid: Bool { return loginQueryState?.isUsernameValid ?? false }
    var isPasswordValid: Bool { return loginQueryState?.isPasswordValid ?? false }
    var shouldLogin: Bool { return loginQueryState?.shouldLogin ?? false }
}

extension LoginStateObject {
    
    static func create() -> (Realm) throws -> LoginStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "loginQueryState": LoginQueryStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(LoginStateObject.self, value: value)
        }
    }
}

