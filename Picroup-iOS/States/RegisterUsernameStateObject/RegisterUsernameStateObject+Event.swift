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
        case onUsernameAvailableSuccess
        case onUsernameAvailableError(Error)
    }
}

extension RegisterUsernameStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeUsername(let username):
            registerParamState?.reduce(event: .onChangeUsername(username), realm: realm)
            registerUsernameAvailableQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onUsernameAvailableSuccess:
            registerUsernameAvailableQueryState?.reduce(event: .onSuccess(""), realm: realm)
        case .onUsernameAvailableError(let error):
            registerUsernameAvailableQueryState?.reduce(event: .onError(error), realm: realm)
        }
    }
}
