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
            sessionState?.reduce(event: .onCreateUser(data), realm: realm)

            setPasswordError = nil
            triggerSetPasswordQuery = false
            
            snackbar?.reduce(event: .onUpdateMessage("密码已修改"), realm: realm)
            
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        case .onSetPasswordError(let error):
            setPasswordError = error.localizedDescription
            triggerSetPasswordQuery = false
            
            snackbar?.reduce(event: .onUpdateMessage(setPasswordError), realm: realm)
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        }
    }
}
