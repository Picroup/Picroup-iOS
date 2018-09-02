//
//  LoginQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/28.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


enum LoginError: LocalizedError {
    case usernameOrPasswordIncorrect
}

extension LoginError {

    var errorDescription: String? {
        switch self {
        case .usernameOrPasswordIncorrect: return "用户名或密码错误"
        }
    }
}

final class LoginQueryStateObject: PrimaryObject {
    
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""
    
    @objc dynamic var sessionState: UserSessionStateObject?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension LoginQueryStateObject {
    var query: LoginQuery? {
        let next = LoginQuery(username: username, password: password)
        return trigger ? next : nil
    }
    var isUsernameValid: Bool { return username.matchExpression(RegularPattern.username) }
    var isPasswordValid: Bool { return password.matchExpression(RegularPattern.password) }
    var shouldLogin: Bool { return isUsernameValid && isPasswordValid && !trigger }
}

extension LoginQueryStateObject {
    
    static func createValues() -> Any {
        return [
            "_id": PrimaryKey.default,
            "sessionState": UserSessionStateObject.createValues(),
        ]
    }
}

extension LoginQueryStateObject {
    
    enum Event {
        case onTrigger
        case onSuccess(UserDetailFragment)
        case onError(Error)
        case onChangeUsername(String)
        case onChangePassword(String)
    }
}

extension LoginQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTrigger:
            guard shouldLogin else { return }
            sessionState?.currentUser = nil
            error = nil
            trigger = true
        case .onSuccess(let data):
            sessionState?.reduce(event: .onCreateUser(data), realm: realm)
            error = nil
            trigger = false
        case .onError(let error):
            sessionState?.currentUser = nil
            self.error = error.localizedDescription
            trigger = false
        case .onChangeUsername(let username):
            self.username = username
        case .onChangePassword(let password):
            self.password = password
        }
    }
}

