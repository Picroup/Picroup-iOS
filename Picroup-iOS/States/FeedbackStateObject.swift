//
//  FeedbackStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import Apollo

final class FeedbackStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var mediumId: String?
    @objc dynamic var toUserId: String?
    @objc dynamic var commentId: String?
    @objc dynamic var kind: String?
    @objc dynamic var content: String = ""
    
    @objc dynamic var savedFeedbackId: String?
    @objc dynamic var savedFeedbackError: String?
    @objc dynamic var triggerSaveFeedback: Bool = false

    @objc dynamic var popRoute: PopRouteObject?
    @objc dynamic var snackbar: SnackbarObject?
}

extension FeedbackStateObject {
    var saveAppFeedbackQuery: SaveAppFeedbackMutation? {
        guard kind == FeedbackKind.app.rawValue,
            !content.isEmpty,
            let userId = session?.currentUserId
            else { return nil }
        let next = SaveAppFeedbackMutation(userId: userId, content: content)
        return triggerSaveFeedback ? next : nil
    }
    var saveUserFeedbackQuery: SaveUserFeedbackMutation? {
        guard kind == FeedbackKind.user.rawValue,
            !content.isEmpty,
            let userId = session?.currentUserId,
            let toUserId = toUserId
            else { return nil }
        let next = SaveUserFeedbackMutation(userId: userId, toUserId: toUserId, content: content)
        return triggerSaveFeedback ? next : nil
    }
    var saveMediumFeedbackQuery: SaveMediumFeedbackMutation? {
        guard kind == FeedbackKind.medium.rawValue,
            !content.isEmpty,
            let userId = session?.currentUserId,
            let mediumId = mediumId
            else { return nil }
        let next = SaveMediumFeedbackMutation(userId: userId, mediumId: mediumId, content: content)
        return triggerSaveFeedback ? next : nil
    }
    var saveCommentFeedbackQuery: SaveCommentFeedbackMutation? {
        guard kind == FeedbackKind.comment.rawValue,
            !content.isEmpty,
            let userId = session?.currentUserId,
            let commentId = commentId
            else { return nil }
        let next = SaveCommentFeedbackMutation(userId: userId, commentId: commentId, content: content)
        return triggerSaveFeedback ? next : nil
    }
    var shouldSaveFeedback: Bool {
        return !triggerSaveFeedback && content.matchExpression(RegularPattern.default)
    }
}

extension FeedbackStateObject {
    
    static func create(kind: String?, toUserId: String?, mediumId: String?, commentId: String?) -> (Realm) throws -> FeedbackStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let feedbackId = PrimaryKey.feedbackId(kind: kind, toUserId: toUserId, mediumId: mediumId, commentId: commentId)
            let value: Snapshot = [
                "_id": feedbackId,
                "session": ["_id": _id],
                "kind": kind,
                "toUserId": toUserId,
                "mediumId": mediumId,
                "commentId": commentId,
                "popRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(FeedbackStateObject.self, value: value)
        }
    }
}

extension FeedbackStateObject {
    
    enum Event {
        
        case onTriggerSaveFeedback
        case onSaveFeedbackSuccess(String)
        case onSaveFeedbackError(Error)
        
        case onChangeContent(String)
        
        case onTriggerPop
    }
}

extension FeedbackStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerSaveFeedback:
            guard shouldSaveFeedback else { return }
            savedFeedbackId = nil
            savedFeedbackError = nil
            triggerSaveFeedback = true
        case .onSaveFeedbackSuccess(let data):
            savedFeedbackId = data
            savedFeedbackError = nil
            triggerSaveFeedback = false
            content = ""
            
            snackbar?.message = "已提交"
            snackbar?.version = UUID().uuidString
            popRoute?.version = UUID().uuidString
        case .onSaveFeedbackError(let error):
            savedFeedbackId = nil
            savedFeedbackError = error.localizedDescription
            triggerSaveFeedback = false
            
            snackbar?.message = error.localizedDescription
            snackbar?.version = UUID().uuidString
        case .onChangeContent(let content):
            self.content = content
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}

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
