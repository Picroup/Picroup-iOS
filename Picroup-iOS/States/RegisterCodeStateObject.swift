//
//  RegisterCodeStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class RegisterCodeStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var registerParam: RegisterParamObject?
    @objc dynamic var isCodeAvaliable: Bool = false
    
    @objc dynamic var registerError: String?
    @objc dynamic var triggerRegisterQuery: Bool = false
    
    @objc dynamic var phoneNumber: String?
    @objc dynamic var getVerifyCodeError: String?
    @objc dynamic var triggerGetVerifyCodeQuery: Bool = false
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension RegisterCodeStateObject {
    var registerQuery: RegisterMutation? {
        guard let username = registerParam?.username,
            let password = registerParam?.password,
            let phoneNumber = registerParam?.phoneNumber,
            let code = registerParam?.code else {
            return nil
        }
        let next = RegisterMutation(username: username, password: password, phoneNumber: phoneNumber, code: code)
        return triggerRegisterQuery ? next : nil
    }
    var getVerifyCodeQuery: GetVerifyCodeMutation? {
        guard let phoneNumber = registerParam?.phoneNumber else { return nil }
        let next = GetVerifyCodeMutation(phoneNumber: phoneNumber)
        return triggerGetVerifyCodeQuery ? next : nil
    }
}

extension RegisterCodeStateObject {
    
    static func create() -> (Realm) throws -> RegisterCodeStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "registerParam": ["_id": _id, "code": 0],
                "isCodeAvaliable": false,
                "phoneNumber": nil,
                "snackbar": ["_id": _id],
                ]
            return try realm.update(RegisterCodeStateObject.self, value: value)
        }
    }
}

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

final class RegisterCodeStateStore {
    
    let states: Driver<RegisterCodeStateObject>
    private let _state: RegisterCodeStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try RegisterCodeStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: RegisterCodeStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: RegisterCodeStateObject.self, forPrimaryKey: id, event: event)
    }
}

