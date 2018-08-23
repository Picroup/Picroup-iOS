//
//  RegisterPasswordStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

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

