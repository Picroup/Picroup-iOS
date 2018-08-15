//
//  ResetPasswordStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class ResetPasswordStateObject: PrimaryObject {
    
    @objc dynamic var resetPasswordParam: ResetPasswordParamObject?
    @objc dynamic var isPasswordValid: Bool = false
    
    @objc dynamic var username: String?
    @objc dynamic var resetPasswordError: String?
    @objc dynamic var triggerResetPasswordQuery: Bool = false
    
    @objc dynamic var backToLoginRoute: BackToLoginRouteObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension ResetPasswordStateObject {
    var resetPasswordQuery: ResetPasswordMutation? {
        guard let phoneNumber = resetPasswordParam?.phoneNumber,
            let password = resetPasswordParam?.password,
            let token = resetPasswordParam?.token else {
                return nil
        }
        return triggerResetPasswordQuery
            ? ResetPasswordMutation(phoneNumber: phoneNumber, password: password, token: token)
            : nil
    }
}

extension ResetPasswordStateObject {
    
    static func create() -> (Realm) throws -> ResetPasswordStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "resetPasswordParam": ["_id": _id, "password": ""],
                "isPasswordValid": false,
                "username": nil,
                "backToLoginRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ResetPasswordStateObject.self, value: value)
        }
    }
}

extension ResetPasswordStateObject {
    
    enum Event {
        case onChangePassword(String)
        
        case onTriggerResetPassword
        case onResetPasswordSuccess(String)
        case onResetPasswordError(Error)
        
        case onConfirmResetPasswordSuccess
    }
}

extension ResetPasswordStateObject: IsFeedbackStateObject {
    
    func reduce(event: ResetPasswordStateObject.Event, realm: Realm) {
        switch event {
        case .onChangePassword(let password):
            self.resetPasswordParam?.password = password
            self.isPasswordValid = password.matchExpression(RegularPattern.password)
            
        case .onTriggerResetPassword:
            guard !triggerResetPasswordQuery else { return }
            resetPasswordError = nil
            triggerResetPasswordQuery = true
        case .onResetPasswordSuccess(let username):
            self.username = username
            resetPasswordError = nil
            triggerResetPasswordQuery = false
        case .onResetPasswordError(let error):
            resetPasswordError = error.localizedDescription
            triggerResetPasswordQuery = false
            snackbar?.message = resetPasswordError
            snackbar?.version = UUID().uuidString
            
        case .onConfirmResetPasswordSuccess:
            backToLoginRoute?.version = UUID().uuidString
        }
    }
}

final class ResetPasswordStateStore {
    
    let states: Driver<ResetPasswordStateObject>
    private let _state: ResetPasswordStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try ResetPasswordStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: ResetPasswordStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: ResetPasswordStateObject.self, forPrimaryKey: id, event: event)
    }
}

