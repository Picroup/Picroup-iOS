//
//  UserBlockingsStateStore.swift
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

final class UserBlockingsStateStore {
    
    let states: Driver<UserBlockingsStateObject>
    private let _state: UserBlockingsStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try UserBlockingsStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: UserBlockingsStateObject.Event) {
        Realm.backgroundReduce(ofType: UserBlockingsStateObject.self, forPrimaryKey: PrimaryKey.default, event: event)
    }
    
    func userBlockingsItems() -> Driver<[UserObject]> {
        return Observable.collection(from: _state.userBlockings)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


