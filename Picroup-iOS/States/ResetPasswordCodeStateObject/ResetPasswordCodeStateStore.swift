//
//  ResetPasswordCodeStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class ResetPasswordCodeStateStore {
    
    let states: Driver<ResetPasswordCodeStateObject>
    private let _state: ResetPasswordCodeStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try ResetPasswordCodeStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: ResetPasswordCodeStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: ResetPasswordCodeStateObject.self, forPrimaryKey: id, event: event)
    }
}

