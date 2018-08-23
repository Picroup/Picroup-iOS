//
//  UpdatePasswordStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

final class UpdatePasswordStateStore {
    
    let states: Driver<UpdatePasswordStateObject>
    private let _state: UpdatePasswordStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try UpdatePasswordStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: UpdatePasswordStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: UpdatePasswordStateObject.self, forPrimaryKey: id, event: event)
    }
}

