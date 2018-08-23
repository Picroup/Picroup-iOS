//
//  CreateImageStateStore.swift
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

final class CreateImageStateStore {
    
    let states: Driver<CreateImageStateObject>
    private let _state: CreateImageStateObject
    
    init(mediaItems: [MediumItem]) throws {
        let realm = try Realm()
        let _state = try CreateImageStateObject.create(mediaItems: mediaItems)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: CreateImageStateObject.Event) {
        Realm.backgroundReduce(ofType: CreateImageStateObject.self, forPrimaryKey: PrimaryKey.default, event: event)
    }
    
    func saveMediumStates() -> Driver<[SaveMediumStateObject]> {
        return Observable.collection(from: _state.saveMediumStates)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
    
    func tagStates() -> Driver<[TagStateObject]> {
        return Observable.collection(from: _state.tagStates)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}
