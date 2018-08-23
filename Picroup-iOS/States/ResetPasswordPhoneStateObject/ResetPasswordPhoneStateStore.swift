//
//  ResetPasswordPhoneStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

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
