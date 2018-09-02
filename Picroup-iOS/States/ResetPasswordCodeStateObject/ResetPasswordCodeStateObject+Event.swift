//
//  ResetPasswordCodeStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


extension ResetPasswordCodeStateObject {
    
    enum Event {
        case onTriggerGetVerifyCode
        case onGetVerifyCodeSuccess(String)
        case onGetVerifyCodeError(Error)
        
        case onChangeCode(String)
        case onValidCodeSuccess
        case onValidCodeError(Error)
        
        case onTriggerVerify
        case onVerifySuccess(String)
        case onVerifyError(Error)
    }
}

extension ResetPasswordCodeStateObject: IsFeedbackStateObject {
    
    func reduce(event: ResetPasswordCodeStateObject.Event, realm: Realm) {
        switch event {
        case .onTriggerGetVerifyCode:
            getVerifyCodeQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onGetVerifyCodeSuccess:
            getVerifyCodeQueryState?.reduce(event: .onSuccess, realm: realm)
        case .onGetVerifyCodeError(let error):
            getVerifyCodeQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)

        case .onChangeCode(let codeText):
            resetPasswordStateParam?.reduce(event: .onChangeCode(codeText), realm: realm)
            codeValidQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onValidCodeSuccess:
            codeValidQueryState?.reduce(event: .onSuccess, realm: realm)
        case .onValidCodeError(let error):
            codeValidQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerVerify:
            verifyCodeQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onVerifySuccess(let token):
            resetPasswordStateParam?.reduce(event: .onChangeToken(token), realm: realm)
            verifyCodeQueryState?.reduce(event: .onSuccess, realm: realm)
            routeState?.reduce(event: .onTriggerResetPassword, realm: realm)
        case .onVerifyError(let error):
            verifyCodeQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
        }
    }
}
