//
//  LoginStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

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
            snackbar?.message = "登录成功"
            snackbar?.version = UUID().uuidString
        case .onLoginError(let error):
            session?.currentUser = nil
            loginError = error.localizedDescription
            triggerLoginQuery = false
            snackbar?.message = loginError
            snackbar?.version = UUID().uuidString
        case .onChangeUsername(let username):
            self.username = username
        case .onChangePassword(let password):
            self.password = password
        }
    }
}
