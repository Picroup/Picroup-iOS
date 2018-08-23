//
//  UserStateStore.swift
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

final class UserStateStore {
    
    let states: Driver<UserStateObject>
    private let _state: UserStateObject
    private let userId: String
    
    init(userId: String) throws {
        let realm = try Realm()
        let _state = try UserStateObject.create(userId: userId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.userId = userId
        self._state = _state
        self.states = states
    }
    
    func on(event: UserStateObject.Event) {
        Realm.backgroundReduce(ofType: UserStateObject.self, forPrimaryKey: userId, event: event)
    }
    
    func userMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.userMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


