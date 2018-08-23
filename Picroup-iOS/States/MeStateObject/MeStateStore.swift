//
//  MeStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class MeStateStore {
    
    let states: Driver<MeStateObject>
    private let _state: MeStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try MeStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: MeStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: MeStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func myMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.myMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.filter { !$0.isInvalidated } }
    }
    
    func myStaredMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.myStaredMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.filter { !$0.isInvalidated } }
    }
}

