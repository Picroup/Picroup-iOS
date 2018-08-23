//
//  UpdateMediumTagsStateStore.swift
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
import RxAlamofire

final class UpdateMediumTagsStateStore {
    
    let mediumId: String
    let states: Driver<UpdateMediumTagsStateObject>
    private let _state: UpdateMediumTagsStateObject
    
    init(mediumId: String) throws {
        let realm = try Realm()
        let _state = try UpdateMediumTagsStateObject.create(mediumId: mediumId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.mediumId = mediumId
        self._state = _state
        self.states = states
    }
    
    func on(event: UpdateMediumTagsStateObject.Event) {
        let id = mediumId
        Realm.backgroundReduce(ofType: UpdateMediumTagsStateObject.self, forPrimaryKey: id, event: event)
    }
    
    func tagStates() -> Driver<[TagStateObject]> {
        return Observable.collection(from: _state.tagStates)
            .asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}
