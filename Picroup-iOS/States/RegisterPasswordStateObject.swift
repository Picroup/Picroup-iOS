//
//  RegisterPasswordStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class RegisterPasswordStateObject: PrimaryObject {
    
    @objc dynamic var registerParam: RegisterParamObject?
    @objc dynamic var isPasswordValid: Bool = false
}

extension RegisterPasswordStateObject {
    
    static func create() -> (Realm) throws -> RegisterPasswordStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "registerParam": ["_id": _id, "password": ""],
                "isPasswordValid": false,
                ]
            return try realm.update(RegisterPasswordStateObject.self, value: value)
        }
    }
}

extension RegisterPasswordStateObject {
    
    enum Event {
        case onChangePassword(String)
    }
}

extension RegisterPasswordStateObject: IsFeedbackStateObject {
    
    func reduce(event: RegisterPasswordStateObject.Event, realm: Realm) {
        switch event {
        case .onChangePassword(let password):
            self.registerParam?.password = password
            self.isPasswordValid = password.count >= minimalPasswordLength
        }
    }
}

final class RegisterPasswordStateStore {
    
    let states: Driver<RegisterPasswordStateObject>
    private let _state: RegisterPasswordStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try RegisterPasswordStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: RegisterPasswordStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: RegisterPasswordStateObject.self, forPrimaryKey: id, event: event)
    }
}

