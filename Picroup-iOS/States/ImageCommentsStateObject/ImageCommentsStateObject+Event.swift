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
        case onTriggerReloadComments
        case onTriggerGetMoreComments
        case onGetCommentsData(CursorCommentsFragment)
        case onGetCommentsError(Error)
        
        case onChangeCommentContent(String)
        case onTriggerSaveComment
        case onSaveCommentSuccess(CommentFragment)
        case onSaveCommentError(Error)
        
        case onTriggerDeleteComment(String)
        case onDeleteCommentSuccess(String)
        case onDeleteCommentError(Error)
        
        case onTriggerLogin
        case onTriggerCommentFeedback(String)
        case onTriggerPop
    }
}

extension ImageCommentsStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onTriggerReloadComments:
            commentsQueryState?.reduce(event: .onTriggerReload, realm: realm)
        case .onTriggerGetMoreComments:
            commentsQueryState?.reduce(event: .onTriggerGetMore, realm: realm)
        case .onGetCommentsData(let data):
            commentsQueryState?.reduce(event: .onGetData(data), realm: realm)
        case .onGetCommentsError(let error):
            commentsQueryState?.reduce(event: .onGetError(error), realm: realm)
            
        case .onChangeCommentContent(let content):
            saveCommentQueryState?.reduce(event: .onChangeContent(content), realm: realm)
        case .onTriggerSaveComment:
            saveCommentQueryState?.reduce(event: .onTrigger, realm: realm)
        case .onSaveCommentSuccess(let data):
            let comment = realm.create(CommentObject.self, value: data.snapshot, update: true)
            commentsQueryState?.reduce(event: .onCreate(comment), realm: realm)
            medium?.reduce(event: .onIncreaseCommentsCount, realm: realm)
            saveCommentQueryState?.reduce(event: .onSuccess, realm: realm)
        case .onSaveCommentError(let error):
            saveCommentQueryState?.reduce(event: .onError(error), realm: realm)
            
        case .onTriggerDeleteComment(let commentId):
            deleteCommentQueryState?.reduce(event: .onTriggerDeleteComment(commentId), realm: realm)
        case .onDeleteCommentSuccess(let commentId):
            deleteCommentQueryState?.reduce(event: .onSuccess(commentId), realm: realm)
            medium?.reduce(event: .onDecreaseCommentsCount, realm: realm)
        case .onDeleteCommentError(let error):
            deleteCommentQueryState?.reduce(event: .onError(error), realm: realm)
            snackbar?.reduce(event: .onUpdateMessage(error.localizedDescription), realm: realm)
            
        case .onTriggerLogin:
            routeState?.reduce(event: .onTriggerLogin, realm: realm)
        case .onTriggerCommentFeedback(let commentId):
            routeState?.reduce(event: .onTriggerCommentFeedback(commentId), realm: realm)
        case .onTriggerPop:
            routeState?.reduce(event: .onTriggerPop, realm: realm)
        }
    }
}
