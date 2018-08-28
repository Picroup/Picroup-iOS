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
            userSetPasswordQueryState?.reduce(event: .onChangeOldPassword(password), realm: realm)
        case .onChangePassword(let password):
            userSetPasswordQueryState?.reduce(event: .onChangePassword(password), realm: realm)
        case .onTriggerSetPassword:
            userSetPasswordQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onSetPasswordSuccess(let data):
            userSetPasswordQueryState?.reduce(event: .onSuccess(data), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage("密码已修改"), realm: realm)
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        case .onSetPasswordError(let error):
            userSetPasswordQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        }
    }
}
