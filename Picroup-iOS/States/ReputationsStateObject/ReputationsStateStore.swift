//
//  ReputationsStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class ReputationsStateStore {
    
    let states: Driver<ReputationsStateObject>
    private let _state: ReputationsStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try ReputationsStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: ReputationsStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: ReputationsStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func reputations() -> Driver<[ReputationObject]> {
        guard let items = _state.reputations?.items else { return .empty() }
        return Observable.collection(from: items)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}


