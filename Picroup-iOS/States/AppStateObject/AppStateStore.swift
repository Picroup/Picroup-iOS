//
//  AppStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import RealmSwift
import RxRealm

final class AppStateStore {
    
    let states: Driver<AppStateObject>
    private let _state: AppStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try AppStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: AppStateObject.Event) {
        let _id = PrimaryKey.default
        Realm.backgroundReduce(ofType: AppStateObject.self, forPrimaryKey: _id, event: event)
    }
    
    func me() -> Driver<UserObject> {
        guard let me = _state.sessionState?.currentUser else { return .empty() }
        return Observable.from(object: me).asDriver(onErrorDriveWith: .empty())
    }
}


