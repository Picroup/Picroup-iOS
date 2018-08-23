//
//  RegisterUsernameStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class RegisterUsernameStateStore {
    
    let states: Driver<RegisterUsernameStateObject>
    private let _state: RegisterUsernameStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try RegisterUsernameStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: RegisterUsernameStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: RegisterUsernameStateObject.self, forPrimaryKey: id, event: event)
    }
}

