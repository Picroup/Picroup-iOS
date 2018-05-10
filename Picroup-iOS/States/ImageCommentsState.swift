//
//  ImageCommentsState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct ImageCommentsState: Mutabled {
    typealias SaveComment = QueryState<SaveCommentMutation, SaveCommentMutation.Data.SaveComment>
    
    var currentUser: UserDetailFragment?

    var medium: MediumFragment
    var next: MediumCommentsQuery
    var items: [CommentFragment]
    var error: Error?
    var trigger: Bool
    
    var nextSaveComment: SaveCommentMutation
    var saveComment: CommentFragment?
    var saveCommentError: Error?
    var triggerSaveComment: Bool
    
}

extension ImageCommentsState {
    var query: MediumCommentsQuery? {
        return trigger ? next : nil
    }
    var shouldQueryMore: Bool {
        return !trigger && next.cursor != nil
    }
    var isItemsEmpty: Bool {
        return !trigger && error == nil && items.isEmpty
    }
    var hasMore: Bool {
        return next.cursor != nil
    }
    var shouldSendComment: Bool {
        return !triggerSaveComment && !nextSaveComment.content.isEmpty
    }
    
    public var saveCommentQuery: SaveCommentMutation? {
        if (currentUser == nil) { return nil }
        return triggerSaveComment ? nextSaveComment : nil
    }
}

extension ImageCommentsState {
    static func empty(medium: MediumFragment) -> ImageCommentsState {
        return ImageCommentsState(
            currentUser: nil,
            medium: medium,
            next: MediumCommentsQuery(
                mediumId: medium.id,
                cursor: nil
            ),
            items: [],
            error: nil,
            trigger: true,
            nextSaveComment: SaveCommentMutation(userId: "", mediumId: medium.id, content: ""),
            saveComment: nil,
            saveCommentError: nil,
            triggerSaveComment: false
        )
    }
}

extension ImageCommentsState: IsFeedbackState {
    enum Event {
        case onUpdateCurrentUser(UserDetailFragment?)
        case onTriggerReload
        case onTriggerGetMore
        case onGetSuccess(CursorCommentsFragment)
        case onGetError(Error)
        case onTriggerSaveComment
        case onSaveCommentSuccess(CommentFragment)
        case onSaveCommentError(Error)
        case onChangeCommentContent(String)
    }
}

extension ImageCommentsState {
    
    static func reduce(state: ImageCommentsState, event: ImageCommentsState.Event) -> ImageCommentsState {
        switch event {
        case .onUpdateCurrentUser(let currentUser):
            return state.mutated {
                $0.currentUser = currentUser
                $0.nextSaveComment.userId = currentUser?.id ?? ""
            }
        case .onTriggerReload:
            return state.mutated {
                $0.next.cursor = nil
                $0.items = []
                $0.error = nil
                $0.trigger = true
            }
        case .onTriggerGetMore:
            guard state.shouldQueryMore else { return state }
            return state.mutated {
                $0.error = nil
                $0.trigger = true
            }
        case .onGetSuccess(let data):
            return state.mutated {
                $0.next.cursor = data.cursor
                $0.items += data.items.flatMap { $0?.fragments.commentFragment }
                $0.error = nil
                $0.trigger = false
            }
        case .onGetError(let error):
            return state.mutated {
                $0.error = error
                $0.trigger = false
            }
        case .onTriggerSaveComment:
            return state.mutated {
                $0.saveComment = nil
                $0.saveCommentError = nil
                $0.triggerSaveComment = true
            }
        case .onSaveCommentSuccess(let data):
            return state.mutated {
                $0.saveComment = data
                $0.saveCommentError = nil
                $0.triggerSaveComment = false
                
                $0.nextSaveComment.content = ""
                $0.items.insert(data, at: 0)
            }
        case .onSaveCommentError(let error):
            return state.mutated {
                $0.saveComment = nil
                $0.saveCommentError = error
                $0.triggerSaveComment = false
            }
        case .onChangeCommentContent(let content):
            return state.mutated {
                $0.nextSaveComment.content = content
            }
        }
    }
    
}


