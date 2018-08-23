//
//  MainStateStore.swift
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

