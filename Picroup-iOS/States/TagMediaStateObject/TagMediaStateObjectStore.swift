//
//  TagMediaStateObjectStore.swift
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



final class TagMediaStateObjectStore {
    
    let tag: String
    let states: Driver<TagMediaStateObject>
    private let _state: TagMediaStateObject
    
    init(tag: String) throws {
        let realm = try Realm()
        let _state = try TagMediaStateObject.create(tag: tag)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.tag = tag
        self._state = _state
        self.states = states
    }
    
    func on(event: TagMediaStateObject.Event) {
        let id = tag
        Realm.backgroundReduce(ofType: TagMediaStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func hotMediaItems() -> Driver<[MediumObject]> {
        guard let items = _state.hotMediaState?.cursorMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            //            .delaySubscription(0.3, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}

