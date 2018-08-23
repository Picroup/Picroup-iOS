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
        case onPhoneNumberAvailableResponse(String?)
    }
}

extension ResetPasswordPhoneStateObject: IsFeedbackStateObject {
    
    func reduce(event: ResetPasswordPhoneStateObject.Event, realm: Realm) {
        switch event {
        case .onChangePhoneNumber(let phoneNumber):
            self.resetPasswordParam?.phoneNumber = phoneNumber
            self.isPhoneNumberValid = false
            guard shouldValidPhone else { return }
            self.triggerValidPhoneQuery = true
        case .onPhoneNumberAvailableResponse(let data):
            self.isPhoneNumberValid = data != nil
            self.triggerValidPhoneQuery = false
        }
    }
}
