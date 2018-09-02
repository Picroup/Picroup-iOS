//
//  RegisterCodeStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


extension RegisterCodeStateObject {
    
    enum Event {
        case onTriggerGetVerifyCode
        case onGetVerifyCodeSuccess(String)
        case onGetVerifyCodeError(Error)
        
        case onChangeCode(String)
        case onValidCodeSuccess
        case onValidCodeError(Error)
        
        case onTriggerRegister
        case onRegisterSuccess(UserDetailFragment)
        case onRegisterError(Error)
    }
}

extension RegisterCodeStateObject: IsFeedbackStateObject {
    
    func reduce(event: RegisterCodeStateObject.Event, realm: Realm) {
        switch event {
        case .onTriggerGetVerifyCode:
            getVerifyCodeQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onGetVerifyCodeSuccess:
            getVerifyCodeQueryState?.reduce(event: .onSuccess, realm: realm)
        case .onGetVerifyCodeError(let error):
            getVerifyCodeQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onChangeCode(let codeText):
            registerParamState?.reduce(event: .onChangeCode(codeText), realm: realm)
            codeValidQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onValidCodeSuccess:
            codeValidQueryState?.reduce(event: .onSuccess, realm: realm)
        case .onValidCodeError(let error):
            codeValidQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerRegister:
            registerQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onRegisterSuccess(let data):
            sessionState?.reduce(event: .onCreateUser(data), realm: realm)
            registerQueryState?.reduce(event: .onSuccess, realm: realm)
            snackbar?.reduce(event: .onUpdateMessage("注册成功"), realm: realm)
        case .onRegisterError(let error):
            registerQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
        }
    }
}
