//
//  FeedbackStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa


final class FeedbackStateStore {
    
    let states: Driver<FeedbackStateObject>
    private let _state: FeedbackStateObject
    private let kind: String?
    private let toUserId: String?
    private let mediumId: String?
    private let commentId: String?
    
    init(kind: String?, toUserId: String?, mediumId: String?, commentId: String?) throws {
        let realm = try Realm()
        let _state = try FeedbackStateObject.create(kind: kind, toUserId: toUserId, mediumId: mediumId, commentId: commentId)(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self.kind = kind
        self.toUserId = toUserId
        self.mediumId = mediumId
        self.commentId = commentId
        self._state = _state
        self.states = states
    }
    
    func on(event: FeedbackStateObject.Event) {
        let feedbackId = PrimaryKey.feedbackId(kind: kind, toUserId: toUserId, mediumId: mediumId, commentId: commentId)
        Realm.backgroundReduce(ofType: FeedbackStateObject.self, forPrimaryKey: feedbackId, event: event)
    }
}
