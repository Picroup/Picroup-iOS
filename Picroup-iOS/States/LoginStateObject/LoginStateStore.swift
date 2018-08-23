//
//  LoginStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class LoginStateStore {
    
    let states: Driver<LoginStateObject>
    private let _state: LoginStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try LoginStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: LoginStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: LoginStateObject.self, forPrimaryKey: id, event: event)
    }
}
