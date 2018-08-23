//
//  HomeStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class HomeStateStore {
    
    let states: Driver<HomeStateObject>
    private let _state: HomeStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try HomeStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: HomeStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: HomeStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func myInterestedMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.myInterestedMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}
