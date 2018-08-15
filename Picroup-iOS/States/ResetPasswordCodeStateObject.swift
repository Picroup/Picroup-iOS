//
//  ResetPasswordCodeStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class ResetPasswordCodeStateObject: PrimaryObject {
    
    @objc dynamic var resetPasswordParam: ResetPasswordParamObject?
    @objc dynamic var isCodeAvaliable: Bool = false
    
    @objc dynamic var verifyCodeError: String?
    @objc dynamic var triggerVerifyCodeQuery: Bool = false
    
    @objc dynamic var phoneNumber: String?
    @objc dynamic var getVerifyCodeError: String?
    @objc dynamic var triggerGetVerifyCodeQuery: Bool = false
    
    @objc dynamic var resetPasswordRoute: ResetPasswordRouteObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension ResetPasswordCodeStateObject {
    var verifyCodeQuery: VerifyCodeQuery? {
        guard let phoneNumber = resetPasswordParam?.phoneNumber,
            let code = resetPasswordParam?.code else {
                return nil
        }
        return triggerVerifyCodeQuery
            ? VerifyCodeQuery(phoneNumber: phoneNumber, code: code)
            : nil
    }
    var getVerifyCodeQuery: GetVerifyCodeMutation? {
        guard let phoneNumber = resetPasswordParam?.phoneNumber else { return nil }
        let next = GetVerifyCodeMutation(phoneNumber: phoneNumber)
        return triggerGetVerifyCodeQuery ? next : nil
    }
}

extension ResetPasswordCodeStateObject {
    
    static func create() -> (Realm) throws -> ResetPasswordCodeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "resetPasswordParam": ["_id": _id, "code": 0],
                "isCodeAvaliable": false,
                "phoneNumber": nil,
                "resetPasswordRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ResetPasswordCodeStateObject.self, value: value)
        }
    }
}

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

final class ResetPasswordCodeStateStore {
    
    let states: Driver<ResetPasswordCodeStateObject>
    private let _state: ResetPasswordCodeStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try ResetPasswordCodeStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: ResetPasswordCodeStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: ResetPasswordCodeStateObject.self, forPrimaryKey: id, event: event)
    }
}

