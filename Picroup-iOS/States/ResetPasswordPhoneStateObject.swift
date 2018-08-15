//
//  ResetPasswordPhoneStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class ResetPasswordParamObject: PrimaryObject {
    
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var token: String = ""
    @objc dynamic var code: Double = 0
}

final class ResetPasswordPhoneStateObject: PrimaryObject {
    
    @objc dynamic var resetPasswordParam: ResetPasswordParamObject?
    @objc dynamic var isPhoneNumberValid: Bool = false
    @objc dynamic var triggerValidPhoneQuery: Bool = false
}

extension ResetPasswordPhoneStateObject {
    var phoneNumberAvailableQuery: PhoneNumberAvailableQuery? {
        guard let phoneNumber = resetPasswordParam?.phoneNumber, !phoneNumber.isEmpty else {
            return nil
        }
        let next = PhoneNumberAvailableQuery(phoneNumber: phoneNumber)
        return triggerValidPhoneQuery ? next : nil
    }
    var shouldValidPhone: Bool {
        guard let phoneNumber = resetPasswordParam?.phoneNumber else { return false }
        return phoneNumber.matchExpression(RegularPattern.chinesePhone)
    }
}

extension ResetPasswordPhoneStateObject {
    
    static func create() -> (Realm) throws -> ResetPasswordPhoneStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "resetPasswordParam": ["_id": _id],
                "isPhoneNumberValid": false,
                ]
            return try realm.update(ResetPasswordPhoneStateObject.self, value: value)
        }
    }
}

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

final class ResetPasswordPhoneStateStore {
    
    let states: Driver<ResetPasswordPhoneStateObject>
    private let _state: ResetPasswordPhoneStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try ResetPasswordPhoneStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: ResetPasswordPhoneStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: ResetPasswordPhoneStateObject.self, forPrimaryKey: id, event: event)
    }
}
