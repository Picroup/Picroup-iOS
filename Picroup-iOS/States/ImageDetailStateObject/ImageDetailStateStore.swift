//
//  ImageDetailStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class ImageDetailStateStore {
    
    let states: Driver<ImageDetailStateObject>
    private let _state: ImageDetailStateObject
    private let mediumId: String
    
    init(mediumId: String) throws {
        let realm = try Realm()
        let _state = try ImageDetailStateObject.create(mediumId: mediumId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.mediumId = mediumId
        self._state = _state
        self.states = states
    }
    
    func on(event: ImageDetailStateObject.Event) {
        Realm.backgroundReduce(ofType: ImageDetailStateObject.self, forPrimaryKey: mediumId, event: event)
    }
    
    func medium() -> Observable<MediumObject> {
        guard let medium = _state.medium else { return .empty() }
        return Observable.from(object: medium).catchErrorJustReturn(medium)
    }
    
    func recommendMediaItems() -> Observable<[MediumObject]> {
        guard let items = _state.recommendMedia?.items else { return .empty() }
        return Observable.collection(from: items)
            .map { $0.toArray() }
            .catchErrorRecoverEmpty()
    }
    
    func mediumWithRecommendMedia() -> Observable<(MediumObject, [MediumObject])> {
        return Observable.combineLatest(medium(), recommendMediaItems())
            .catchErrorRecoverEmpty()
    }
}
