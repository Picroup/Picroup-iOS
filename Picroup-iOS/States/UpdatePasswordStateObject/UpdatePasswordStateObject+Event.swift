//
//  UpdatePasswordStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

extension UpdatePasswordStateObject {
    
    enum Event {
        case onChangeOldPassword(String)
        case onChangePassword(String)
        
        case onTriggerSetPassword
        case onSetPasswordSuccess(UserFragment)
        case onSetPasswordError(Error)
        
        case onTriggerPop
    }
}

extension UpdatePasswordStateObject: IsFeedbackStateObject {
    
    func reduce(event: UpdatePasswordStateObject.Event, realm: Realm) {
        switch event {
        case .onChangeOldPassword(let password):
            self.oldPassword = password
            self.isOldPasswordValid = password.matchExpression(RegularPattern.password)
        case .onChangePassword(let password):
            self.password = password
            self.isPasswordValid = password.matchExpression(RegularPattern.password)
            
        case .onTriggerSetPassword:
            guard shouldSetPassword else { return }
            setPasswordError = nil
            triggerSetPasswordQuery = true
        case .onSetPasswordSuccess(let data):
            session?.currentUser = UserObject.create(from: data)(realm)
            setPasswordError = nil
            triggerSetPasswordQuery = false
            
            snackbar?.message = "密码已修改"
            snackbar?.version = UUID().uuidString
            
            popRoute?.version = UUID().uuidString
        case .onSetPasswordError(let error):
            setPasswordError = error.localizedDescription
            triggerSetPasswordQuery = false
            
            snackbar?.message = setPasswordError
            snackbar?.version = UUID().uuidString
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}
