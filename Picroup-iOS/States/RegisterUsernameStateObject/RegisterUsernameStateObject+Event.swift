//
//  RegisterUsernameStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

extension RegisterUsernameStateObject {
    
    enum Event {
        case onChangeUsername(String)
        case onUsernameAvailableResponse(String?)
    }
}

extension RegisterUsernameStateObject: IsFeedbackStateObject {
    
    func reduce(event: RegisterUsernameStateObject.Event, realm: Realm) {
        switch event {
        case .onChangeUsername(let username):
            self.registerParam?.username = username
            self.isUsernameAvaliable = false
            guard shouldValidUsername else { return }
            self.triggerValidUsernameQuery = true
        case .onUsernameAvailableResponse(let data):
            self.isUsernameAvaliable = data == nil
            self.triggerValidUsernameQuery = false
        }
    }
}
