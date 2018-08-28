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
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerLogin:
            loginQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onLoginSuccess(let data):
            loginQueryState?.reduce(event: .onSuccess(data), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage("登录成功"), realm: realm)
        case .onLoginError(let error):
            loginQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
        case .onChangeUsername(let username):
            loginQueryState?.reduce(event: .onChangeUsername(username), realm: realm)
        case .onChangePassword(let password):
            loginQueryState?.reduce(event: .onChangePassword(password), realm: realm)
        }
    }
}
