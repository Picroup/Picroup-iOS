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
            self.resetPasswordParam?.password = password
            self.isPasswordValid = password.matchExpression(RegularPattern.password)
            
        case .onTriggerResetPassword:
            guard !triggerResetPasswordQuery else { return }
            resetPasswordError = nil
            triggerResetPasswordQuery = true
        case .onResetPasswordSuccess(let username):
            self.username = username
            resetPasswordError = nil
            triggerResetPasswordQuery = false
        case .onResetPasswordError(let error):
            resetPasswordError = error.localizedDescription
            triggerResetPasswordQuery = false
            snackbar?.reduce(event: .onUpdateMessage(resetPasswordError), realm: realm)
            
        case .onConfirmResetPasswordSuccess:
            backToLoginRoute?.version = UUID().uuidString
        }
    }
}
