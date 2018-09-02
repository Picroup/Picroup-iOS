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
        case onValidPasswordSuccess
        case onValidPasswordError(Error)
    }
}

extension RegisterPasswordStateObject: IsFeedbackStateObject {
    
    func reduce(event: RegisterPasswordStateObject.Event, realm: Realm) {
        switch event {
        case .onChangePassword(let password):
            registerParamState?.reduce(event: .onChangePassword(password), realm: realm)
            passwordValidQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onValidPasswordSuccess:
            passwordValidQueryState?.reduce(event: .onSuccess, realm: realm)
        case .onValidPasswordError(let error):
            passwordValidQueryState?.reduce(event: .onError(error), realm: realm)
        }
    }
}
