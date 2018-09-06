//
//  ResetPasswordStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


extension ResetPasswordStateObject {
    
    enum Event {
        case onChangePassword(String)
        case onValidPasswordSuccess
        case onValidPasswordError(Error)
        
        case onTriggerResetPassword
        case onResetPasswordSuccess(String)
        case onResetPasswordError(Error)
        
        case onConfirmResetPasswordSuccess
    }
}

extension ResetPasswordStateObject: IsFeedbackStateObject {
    
    func reduce(event: ResetPasswordStateObject.Event, realm: Realm) {
        switch event {
        case .onChangePassword(let password):
            resetPasswordParamState?.reduce(event: .onChangePassword(password), realm: realm)
            passwordValidQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onValidPasswordSuccess:
            passwordValidQueryState?.reduce(event: .onSuccess(""), realm: realm)
        case .onValidPasswordError(let error):
            passwordValidQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerResetPassword:
            resetPasswordQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onResetPasswordSuccess(let username):
            resetPasswordQueryState?.reduce(event: .onSuccess(username), realm: realm)
        case .onResetPasswordError(let error):
            resetPasswordQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)

        case .onConfirmResetPasswordSuccess:
            routeState?.reduce(event: .onTriggerBackToLogin, realm: realm)
        }
    }
}
