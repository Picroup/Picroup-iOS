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

enum LoginError: LocalizedError {
    case usernameOrPasswordIncorrect
}

extension LoginError {
    
    var errorDescription: String {
        switch self {
        case .usernameOrPasswordIncorrect: return "用户名或密码错误"
        }
    }
}

final class LoginStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var loginError: String?
    @objc dynamic var triggerLoginQuery: Bool = false
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension LoginStateObject {
    var loginQuery: LoginQuery? {
        let next = LoginQuery(username: username, password: password)
        return triggerLoginQuery ? next : nil
    }
    var isUsernameValid: Bool { return username.matchExpression(RegularPattern.username) }
    var isPasswordValid: Bool { return password.matchExpression(RegularPattern.password) }
    var shouldLogin: Bool { return isUsernameValid && isPasswordValid && !triggerLoginQuery }
}

extension LoginStateObject {
    
    static func create() -> (Realm) throws -> LoginStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(LoginStateObject.self, value: value)
        }
    }
}

