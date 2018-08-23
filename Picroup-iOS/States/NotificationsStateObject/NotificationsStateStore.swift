//
//  NotificationsStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class NotificationsStateStore {
    
    let states: Driver<NotificationsStateObject>
    private let _state: NotificationsStateObject
    
    init() throws {
        
        let realm = try Realm()
        let _state = try NotificationsStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: NotificationsStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: NotificationsStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func notifications() -> Driver<[NotificationObject]> {
        guard let items = _state.notifications?.items else { return .empty() }
        return Observable.collection(from: items)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}

