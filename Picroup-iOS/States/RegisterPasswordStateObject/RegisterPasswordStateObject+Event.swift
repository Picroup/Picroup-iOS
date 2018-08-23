//
//  RegisterPasswordStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


extension RegisterPasswordStateObject {
    
    enum Event {
        case onChangePassword(String)
    }
}

extension RegisterPasswordStateObject: IsFeedbackStateObject {
    
    func reduce(event: RegisterPasswordStateObject.Event, realm: Realm) {
        switch event {
        case .onChangePassword(let password):
            self.registerParam?.password = password
            self.isPasswordValid = password.matchExpression(RegularPattern.password)
        }
    }
}
