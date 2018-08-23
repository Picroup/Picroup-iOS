//
//  ImageCommentsStateObject+Event.swift
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
        
        case onTriggerLogin
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
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onTriggerLogin:
            loginRoute?.version = UUID().uuidString
        case .onTriggerCommentFeedback(let commentId):
            feedbackRoute?.triggerComment(commentId: commentId)
        case .onTriggerPop:
            popRoute?.version = UUID().uuidString
        }
    }
}
