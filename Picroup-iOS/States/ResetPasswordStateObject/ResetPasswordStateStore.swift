//
//  ResetPasswordStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

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
