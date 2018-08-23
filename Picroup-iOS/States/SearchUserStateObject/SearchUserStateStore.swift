//
//  SearchUserStateStore.swift
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

final class SearchUserStateStore {
    
    let states: Driver<SearchUserStateObject>
    private let _state: SearchUserStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try SearchUserStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: SearchUserStateObject.Event) {
        Realm.backgroundReduce(ofType: SearchUserStateObject.self, forPrimaryKey: PrimaryKey.default, event: event)
    }
    
    func usersItems() -> Driver<[UserObject]> {
        return states.map {
            guard $0.user != nil else { return [] }
            return [$0.user!]
        }
    }
}

