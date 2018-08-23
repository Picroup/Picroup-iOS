//
//  UserFollowersStateStore.swift
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

final class UserFollowersStateStore {
    
    let states: Driver<UserFollowersStateObject>
    private let _state: UserFollowersStateObject
    private let userId: String
    
    init(userId: String) throws {
        let realm = try Realm()
        let _state = try UserFollowersStateObject.create(userId: userId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.userId = userId
        self._state = _state
        self.states = states
    }
    
    func on(event: UserFollowersStateObject.Event) {
        Realm.backgroundReduce(ofType: UserFollowersStateObject.self, forPrimaryKey: userId, event: event)
    }
    
    func userFollowersItems() -> Driver<[UserObject]> {
        guard let items = _state.userFollowers?.items else { return .empty() }
        return Observable.collection(from: items)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


