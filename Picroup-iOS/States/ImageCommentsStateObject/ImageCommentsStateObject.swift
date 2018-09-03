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

final class ImageCommentsStateObject: VersionedPrimaryObject {
    
    @objc dynamic var sessionState: UserSessionStateObject?
//    @objc dynamic var isMediumDeleted: Bool = false

    @objc dynamic var medium: MediumObject?
    
    @objc dynamic var commentsQueryState: MediumCommentsQueryStateObject?
    @objc dynamic var saveCommentQueryState: SaveCommentQueryStateObject?
    @objc dynamic var deleteCommentQueryState: DeleteCommentQueryStateObject?
    
    @objc dynamic var routeState: RouteStateObject?
    
    @objc dynamic var snackbar: SnackbarObject?
}

extension ImageCommentsStateObject {
    var mediumId: String { return _id }
    var commentsQuery: MediumCommentsQuery? {
        return commentsQueryState?.query(mediumId: mediumId)
    }
    public var saveCommentQuery: SaveCommentMutation? {
        return saveCommentQueryState?.query(userId: sessionState?.currentUserId)
    }
    public var deleteCommentQuery: DeleteCommentMutation? {
        return deleteCommentQueryState?.query(userId: sessionState?.currentUserId)
    }
}

extension ImageCommentsStateObject {
    
    static func create(mediumId: String) -> (Realm) throws -> ImageCommentsStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": mediumId,
                "sessionState": UserSessionStateObject.createValues(),
                "medium": ["_id": mediumId],
                "commentsQueryState": MediumCommentsQueryStateObject.createValues(id: PrimaryKey.commentsId(mediumId)),
                "saveCommentQueryState": SaveCommentQueryStateObject.createValues(id: mediumId),
                "deleteCommentQueryState": DeleteCommentQueryStateObject.createValues(),
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ImageCommentsStateObject.self, value: value)
        }
    }
}

final class DeleteCommentQueryStateObject: PrimaryObject {
    
    @objc dynamic var deleteComment: CommentObject?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension DeleteCommentQueryStateObject {
    var shouldQuery: Bool {
        return !trigger
    }
    func query(userId: String?) -> DeleteCommentMutation? {
        guard deleteComment?.userId == userId,
            let commentId = deleteComment?._id else { return nil }
        return trigger == true
            ? DeleteCommentMutation(commentId: commentId)
            : nil
    }
}

extension DeleteCommentQueryStateObject {
    
    static func createValues() -> Any {
        return  [
            "_id": PrimaryKey.default,
        ]
    }
}
extension DeleteCommentQueryStateObject {
    
    enum Event {
        case onTriggerDeleteComment(String)
        case onSuccess(String)
        case onError(Error)
    }
}

extension DeleteCommentQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerDeleteComment(let commentId):
            guard shouldQuery else { return }
            deleteComment = realm.object(ofType: CommentObject.self, forPrimaryKey: commentId)
            error = nil
            trigger = true
        case .onSuccess(let commentId):
            realm.object(ofType: CommentObject.self, forPrimaryKey: commentId)?.delete()
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
        }
    }
}


