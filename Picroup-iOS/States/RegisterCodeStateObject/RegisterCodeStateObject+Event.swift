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
        case onChangeCode(String)
        
        case onTriggerRegister
        case onRegisterSuccess(UserDetailFragment)
        case onRegisterError(Error)
        
        case onTriggerGetVerifyCode
        case onGetVerifyCodeSuccess(String)
        case onGetVerifyCodeError(Error)
    }
}

extension RegisterCodeStateObject: IsFeedbackStateObject {
    
    func reduce(event: RegisterCodeStateObject.Event, realm: Realm) {
        switch event {
        case .onChangeCode(let codeText):
            let code = Double(codeText) ?? 0
            self.registerParam?.code = code
            self.isCodeAvaliable = codeText.matchExpression(RegularPattern.code6)
            
        case .onTriggerRegister:
            guard !triggerRegisterQuery else { return }
            registerError = nil
            triggerRegisterQuery = true
        case .onRegisterSuccess(let data):
            session?.currentUser = UserObject.create(from: data)(realm)
            registerError = nil
            triggerRegisterQuery = false
            snackbar?.message = "注册成功"
            snackbar?.version = UUID().uuidString
        case .onRegisterError(let error):
            registerError = error.localizedDescription
            triggerRegisterQuery = false
            snackbar?.message = registerError
            snackbar?.version = UUID().uuidString
            
        case .onTriggerGetVerifyCode:
            phoneNumber = nil
            getVerifyCodeError = nil
            triggerGetVerifyCodeQuery = true
        case .onGetVerifyCodeSuccess(let phoneNumber):
            self.phoneNumber = phoneNumber
            getVerifyCodeError = nil
            triggerGetVerifyCodeQuery = false
        case .onGetVerifyCodeError(let error):
            phoneNumber = nil
            getVerifyCodeError = error.localizedDescription
            triggerGetVerifyCodeQuery = false
            
            snackbar?.message = getVerifyCodeError
            snackbar?.version = UUID().uuidString
        }
    }
}
