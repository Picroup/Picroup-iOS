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
import RxFeedback

extension ImageCommentsStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryComments: @escaping (MediumCommentsQuery) -> Single<CursorCommentsFragment>,
        saveComment: @escaping (SaveCommentMutation) -> Single<CommentFragment>,
        deleteComment: @escaping (DeleteCommentMutation) -> Single<String>
        ) -> Driver<ImageCommentsStateObject> {
        
        let queryCommentsFeedback: DriverFeedback = react(query: { $0.commentsQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryComments(query)
                .map(Event.onGetCommentsData)
                .asSignal(onErrorReturnJust: (Event.onGetCommentsError))
        })
        
        let saveCommentFeedback: DriverFeedback = react(query: { $0.saveCommentQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return saveComment(query)
                .map(Event.onSaveCommentSuccess)
                .asSignal(onErrorReturnJust: (Event.onSaveCommentError))
        })
        
        let deleteCommentFeedback: DriverFeedback = react(query: { $0.deleteCommentQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return deleteComment(query)
                .map(Event.onDeleteCommentSuccess)
                .asSignal(onErrorReturnJust: (Event.onDeleteCommentError))
        })
        
        return system(
            feedbacks: [uiFeedback, queryCommentsFeedback, saveCommentFeedback, deleteCommentFeedback],
            //            composeStates: { $0.debug("ImageCommentsState", trimOutput: false) },
            composeEvents: { $0.debug("ImageCommentsState.Event", trimOutput: true) }
        )
    }
}
