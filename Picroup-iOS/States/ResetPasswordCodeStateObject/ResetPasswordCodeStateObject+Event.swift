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
        case onChangeCode(String)
        
        case onTriggerVerify
        case onVerifySuccess(String)
        case onVerifyError(Error)
        
        case onTriggerGetVerifyCode
        case onGetVerifyCodeSuccess(String)
        case onGetVerifyCodeError(Error)
    }
}

extension ResetPasswordCodeStateObject: IsFeedbackStateObject {
    
    func reduce(event: ResetPasswordCodeStateObject.Event, realm: Realm) {
        switch event {
        case .onChangeCode(let codeText):
            let code = Double(codeText) ?? 0
            self.resetPasswordParam?.code = code
            self.isCodeAvaliable = codeText.matchExpression(RegularPattern.code6)
            
        case .onTriggerVerify:
            guard !triggerVerifyCodeQuery else { return }
            verifyCodeError = nil
            triggerVerifyCodeQuery = true
        case .onVerifySuccess(let token):
            self.resetPasswordParam?.token = token
            verifyCodeError = nil
            triggerVerifyCodeQuery = false
            
            resetPasswordRoute?.version = UUID().uuidString
            
        case .onVerifyError(let error):
            verifyCodeError = error.localizedDescription
            triggerVerifyCodeQuery = false
            
            snackbar?.message = verifyCodeError
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
