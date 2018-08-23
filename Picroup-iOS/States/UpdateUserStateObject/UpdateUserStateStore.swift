//
//  UpdateUserStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxAlamofire

final class UpdateUserStateStore {
    
    let states: Driver<UpdateUserStateObject>
    private let _state: UpdateUserStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try UpdateUserStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: UpdateUserStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: UpdateUserStateObject.self, forPrimaryKey: id, event: event)
    }
}
