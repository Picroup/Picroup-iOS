//
//  RegisterPhoneStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

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
