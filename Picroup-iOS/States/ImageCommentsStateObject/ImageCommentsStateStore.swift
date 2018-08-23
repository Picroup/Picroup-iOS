//
//  ImageCommentsStateStore.swift
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

final class ImageCommentsStateStore {
    
    let states: Driver<ImageCommentsStateObject>
    private let _state: ImageCommentsStateObject
    private let mediumId: String
    
    init(mediumId: String) throws {
        let realm = try Realm()
        let _state = try ImageCommentsStateObject.create(mediumId: mediumId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.mediumId = mediumId
        self._state = _state
        self.states = states
    }
    
    func on(event: ImageCommentsStateObject.Event) {
        Realm.backgroundReduce(ofType: ImageCommentsStateObject.self, forPrimaryKey: mediumId, event: event)
    }
    
    func medium() -> Observable<MediumObject> {
        guard let medium = _state.medium else { return .empty() }
        return Observable.from(object: medium).catchErrorRecoverEmpty()
        
    }
    
    func commentsItems() -> Driver<[CommentObject]> {
        guard let items = _state.comments?.items else { return .empty() }
        return Observable.collection(from: items).asDriver(onErrorDriveWith: .empty())
            .map { $0.toArray() }
    }
}
