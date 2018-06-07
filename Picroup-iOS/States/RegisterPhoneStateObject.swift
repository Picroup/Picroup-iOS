//
//  RegisterPhoneStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class RegisterPhoneStateObject: PrimaryObject {
    
    @objc dynamic var registerParam: RegisterParamObject?
    @objc dynamic var isPhoneNumberValid: Bool = false
}

extension RegisterPhoneStateObject {
    
    static func create() -> (Realm) throws -> RegisterPhoneStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "registerParam": ["_id": _id],
            ]
            return try realm.update(RegisterPhoneStateObject.self, value: value)
        }
    }
}

extension RegisterPhoneStateObject {
    
    enum Event {
        case onChangePhoneNumber(String)
    }
}

extension RegisterPhoneStateObject: IsFeedbackStateObject {
    
    func reduce(event: RegisterPhoneStateObject.Event, realm: Realm) {
        switch event {
        case .onChangePhoneNumber(let phoneNumber):
            self.registerParam?.phoneNumber = phoneNumber
            self.isPhoneNumberValid = phoneNumber.matchExpression(RegularPattern.chinesePhone)
        }
    }
}

final class RegisterPhoneStateStore {
    
    let states: Driver<RegisterPhoneStateObject>
    private let _state: RegisterPhoneStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try RegisterPhoneStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: RegisterPhoneStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: RegisterPhoneStateObject.self, forPrimaryKey: id, event: event)
    }
}

