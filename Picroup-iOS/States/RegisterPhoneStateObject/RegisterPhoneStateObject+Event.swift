//
//  RegisterPhoneStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


extension RegisterPhoneStateObject {
    
    enum Event {
        case onChangePhoneNumber(String)
        case onPhoneNumberAvailableSuccess
        case onPhoneNumberAvailableError(Error)
    }
}

extension RegisterPhoneStateObject: IsFeedbackStateObject {
    
    func reduce(event: RegisterPhoneStateObject.Event, realm: Realm) {
        switch event {
        case .onChangePhoneNumber(let phoneNumber):
            registerParamState?.reduce(event: .onChangePhoneNumber(phoneNumber), realm: realm)
            registerPhoneAvailableQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onPhoneNumberAvailableSuccess:
            registerPhoneAvailableQueryState?.reduce(event: .onSuccess(""), realm: realm)
        case .onPhoneNumberAvailableError(let error):
            registerPhoneAvailableQueryState?.reduce(event: .onError(error), realm: realm)
        }
    }
}
