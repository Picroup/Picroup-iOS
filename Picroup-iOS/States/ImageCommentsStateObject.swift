//
//  ImageCommentsStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class ImageCommentsStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    @objc dynamic var isMediumDeleted: Bool = false

    @objc dynamic var medium: MediumObject?
    
    @objc dynamic var comments: CursorCommentsObject?
    @objc dynamic var commentsError: String?
    @objc dynamic var triggerCommentsQuery: Bool = false
    
    @objc dynamic var saveCommentContent: String = ""
    @objc dynamic var saveCommentVersion: String?
    @objc dynamic var saveCommentError: String?
    @objc dynamic var triggerSaveComment: Bool = false
    
    @objc dynamic var deleteComment: CommentObject?
    @objc dynamic var deleteCommentError: String?
    @objc dynamic var triggerDeleteComment: Bool = false
    
    @objc dynamic var feedbackRoute: FeedbackRouteObject?
    @objc dynamic var popRoute: PopRouteObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension ImageCommentsStateObject {
    var mediumId: String { return _id }
    var commentsQuery: MediumCommentsQuery? {
        let next = MediumCommentsQuery(mediumId: mediumId, cursor: comments?.cursor.value)
        return triggerCommentsQuery ? next : nil
    }
    var shouldQueryMoreComments: Bool {
        return !triggerCommentsQuery && hasMoreComments
    }
    var isCommentsEmpty: Bool {
        guard let items = comments?.items else { return false }
        return !triggerCommentsQuery && commentsError == nil && items.isEmpty
    }
    var hasMoreComments: Bool {
        return comments?.cursor.value != nil
    }
    var shouldSendComment: Bool {
        return !triggerSaveComment && saveCommentContent.matchExpression(RegularPattern.default)
    }
    public var saveCommentQuery: SaveCommentMutation? {
        guard let userId = session?.currentUser?._id else { return nil }
        let next = SaveCommentMutation(userId: userId, mediumId: mediumId, content: saveCommentContent)
        return triggerSaveComment ? next : nil
    }
    public var deleteCommentQuery: DeleteCommentMutation? {
        guard deleteComment?.userId == session?.currentUser?._id,
            let commentId = deleteComment?._id else { return nil }
        let next = DeleteCommentMutation(commentId: commentId)
        return triggerDeleteComment ? next : nil
    }
}

extension ImageCommentsStateObject {
    
    static func create(mediumId: String) -> (Realm) throws -> ImageCommentsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": mediumId,
                "session": ["_id": _id],
                "medium": ["_id": mediumId],
                "comments": ["_id": PrimaryKey.commentsId(mediumId)],
                "feedbackRoute": ["_id": _id],
                "popRoute": ["_id": _id],
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ImageCommentsStateObject.self, value: value)
        }
    }
}

extension ImageCommentsStateObject {
    
    enum Event {
        case onTriggerReloadData
        case onTriggerGetMoreData
        case onGetReloadData(CursorCommentsFragment?)
        case onGetMoreData(CursorCommentsFragment?)
        case onGetDataError(Error)
        
        case onTriggerSaveComment
        case onSaveCommentSuccess(CommentFragment)
        case onSaveCommentError(Error)
        
        case onChangeCommentContent(String)
        
        case onTriggerDeleteComment(String)
        case onDeleteCommentSuccess(String)
        case onDeleteCommentError(Error)

        case onTriggerCommentFeedback(String)
        case onTriggerPop
    }
}

extension ImageCommentsStateObject.Event {
    
    static func onGetData(isReload: Bool) -> (CursorCommentsFragment?) -> ImageCommentsStateObject.Event {
        return { isReload ? .onGetReloadData($0) : .onGetMoreData($0) }
    }
}

extension ImageCommentsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadData:
            comments?.cursor.value = nil
            commentsError = nil
            triggerCommentsQuery = true
        case .onTriggerGetMoreData:
            guard shouldQueryMoreComments else { return }
            commentsError = nil
            triggerCommentsQuery = true
        case .onGetReloadData(let data):
            if let data = data {
                comments = CursorCommentsObject.create(from: data, id: PrimaryKey.commentsId(_id))(realm)
            } else {
                medium?.delete()
                isMediumDeleted = true
            }
            commentsError = nil
            triggerCommentsQuery = false
        case .onGetMoreData(let data):
            if let data = data {
                comments?.merge(from: data)(realm)
            } else {
                medium?.delete()
                isMediumDeleted = true
            }
            commentsError = nil
            triggerCommentsQuery = false
        case .onGetDataError(let error):
            commentsError = error.localizedDescription
            triggerCommentsQuery = false
        case .onTriggerSaveComment:
            guard shouldSendComment else { return }
            saveCommentVersion = nil
            saveCommentError = nil
            triggerSaveComment = true
        case .onSaveCommentSuccess(let data):
            let comment = realm.create(CommentObject.self, value: data.snapshot, update: true)
            comments?.items.insert(comment, at: 0)
            medium?.commentsCount.value?.increase(1)
            saveCommentVersion = UUID().uuidString
            saveCommentError = nil
            triggerSaveComment = false
            saveCommentContent = ""
        case .onSaveCommentError(let error):
            saveCommentVersion = nil
            saveCommentError = error.localizedDescription
            triggerSaveComment = false
        case .onChangeCommentContent(let content):
            saveCommentContent = content
            
        case .onTriggerDeleteComment(let commentId):
            guard !triggerDeleteComment else { return }
            deleteComment = realm.object(ofType: CommentObject.self, forPrimaryKey: commentId)
            deleteCommentError = nil
            triggerDeleteComment = true
        case .onDeleteCommentSuccess(let commentId):
            realm.object(ofType: CommentObject.self, forPrimaryKey: commentId)?.delete()
            medium?.commentsCount.value?.increase(-1)
            deleteCommentError = nil
            triggerDeleteComment = false
        case .onDeleteCommentError(let error):
            deleteCommentError = error.localizedDescription
            triggerDeleteComment = false
            snackbar?.message = error.localizedDescription
            snackbar?.version = UUID().uuidString
            
        case .onTriggerCommentFeedback(let commentId):
            feedbackRoute?.triggerComment(commentId: commentId)
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}

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
