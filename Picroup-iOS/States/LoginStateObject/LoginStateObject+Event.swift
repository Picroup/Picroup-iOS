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
            sessionState?.currentUser = nil
            loginError = nil
            triggerLoginQuery = true
        case .onLoginSuccess(let data):
            sessionState?.reduce(event: .onCreateUser(data), realm: realm)
            loginError = nil
            triggerLoginQuery = false
            snackbar?.reduce(event: .onUpdateMessage("登录成功"), realm: realm)
        case .onLoginError(let error):
            sessionState?.currentUser = nil
            loginError = error.localizedDescription
            triggerLoginQuery = false
            snackbar?.reduce(event: .onUpdateMessage(loginError), realm: realm)
        case .onChangeUsername(let username):
            self.username = username
        case .onChangePassword(let password):
            self.password = password
        }
    }
}
