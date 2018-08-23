//
//  RegisterCodeStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

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

