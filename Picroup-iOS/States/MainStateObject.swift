//
//  MainStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class MainStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
}

extension MainStateObject {
    
    static func create() -> (Realm) throws -> MainStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                ]
            return try realm.findOrCreate(MainStateObject.self, forPrimaryKey: _id, value: value)
        }
    }
}

extension MainStateObject {
    
    enum Event {
    }
}

extension MainStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {

    }
}

final class MainStateStore {
    
    let states: Driver<MainStateObject>
    let state: MainStateObject
    
    init() throws {
        let realm = try Realm()
        let state = try MainStateObject.create()(realm)
        let states = Observable.from(object: state).asDriver(onErrorDriveWith: .empty())
        
        self.state = state
        self.states = states
    }
    
    func on(event: MainStateObject.Event) {
        let id = PrimaryKey.default
        Realm.backgroundReduce(ofType: MainStateObject.self, forPrimaryKey: id, event: event)
    }
}

