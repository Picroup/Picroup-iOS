//
//  ResetPasswordPhoneStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


extension ResetPasswordPhoneStateObject {
    
    enum Event {
        case onChangePhoneNumber(String)
        case onPhoneNumberAvailableSuccess
        case onPhoneNumberAvailableError(Error)
    }
}

extension ResetPasswordPhoneStateObject: IsFeedbackStateObject {
    
    func reduce(event: ResetPasswordPhoneStateObject.Event, realm: Realm) {
        switch event {
        case .onChangePhoneNumber(let phoneNumber):
            resetPasswordParamState?.reduce(event: .onChangePhoneNumber(phoneNumber), realm: realm)
            resetPhoneAvailableQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onPhoneNumberAvailableSuccess:
            resetPhoneAvailableQueryState?.reduce(event: .onSuccess(""), realm: realm)
        case .onPhoneNumberAvailableError(let error):
            resetPhoneAvailableQueryState?.reduce(event: .onError(error), realm: realm)
        }
    }
}
