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

private let minimalUsernameLength = 0
private let minimalPasswordLength = 0

final class LoginStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var loginError: String?
    @objc dynamic var triggerLoginQuery: Bool = false
}

extension LoginStateObject {
    var loginQuery: LoginQuery? {
        let next = LoginQuery(username: username, password: password)
        return triggerLoginQuery ? next : nil
    }
    var isUsernameValid: Bool { return username.count > minimalUsernameLength }
    var isPasswordValid: Bool { return password.count > minimalPasswordLength }
    var shouldLogin: Bool { return isUsernameValid && isPasswordValid && !triggerLoginQuery }
}

extension LoginStateObject {
    
    static func create() -> (Realm) throws -> LoginStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
            ]
            return try realm.findOrCreate(LoginStateObject.self, forPrimaryKey: _id, value: value)
        }
    }
}

extension LoginStateObject {
    
    enum Event {
        case onTriggerLogin
        case onLoginSuccess(UserDetailFragment)
        case onLoginError(Error)
        case onChangeUsername(String)
        case onChangePassword(String)
    }
}

extension LoginStateObject: IsFeedbackStateObject {
    
    func reduce(event: LoginStateObject.Event, realm: Realm) {
        switch event {
        case .onTriggerLogin:
            guard shouldLogin else { return }
            session?.currentUser = nil
            loginError = nil
            triggerLoginQuery = true
        case .onLoginSuccess(let data):
            session?.currentUser = UserObject.create(from: data)(realm)
            loginError = nil
            triggerLoginQuery = false
        case .onLoginError(let error):
            session?.currentUser = nil
            loginError = error.localizedDescription
            triggerLoginQuery = false
        case .onChangeUsername(let username):
            self.username = username
        case .onChangePassword(let password):
            self.password = password
        }
    }
}


final class LoginStateStore {
    
    let states: Driver<LoginStateObject>
    private let _state: LoginStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try LoginStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: LoginStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: LoginStateObject.self, forPrimaryKey: id, event: event)
    }
}