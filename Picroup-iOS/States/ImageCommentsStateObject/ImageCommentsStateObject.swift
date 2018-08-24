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
    
    @objc dynamic var sessionState: UserSessionStateObject?
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
    
    @objc dynamic var routeState: RouteStateObject?
    
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
        guard let userId = sessionState?.currentUserId else { return nil }
        let next = SaveCommentMutation(userId: userId, mediumId: mediumId, content: saveCommentContent)
        return triggerSaveComment ? next : nil
    }
    public var deleteCommentQuery: DeleteCommentMutation? {
        guard deleteComment?.userId == sessionState?.currentUserId,
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
                "sessionState": UserSessionStateObject.createValues(),
                "medium": ["_id": mediumId],
                "comments": ["_id": PrimaryKey.commentsId(mediumId)],
                "routeState": RouteStateObject.createValues(),
                "snackbar": ["_id": _id],
                ]
            return try realm.update(ImageCommentsStateObject.self, value: value)
        }
    }
}

