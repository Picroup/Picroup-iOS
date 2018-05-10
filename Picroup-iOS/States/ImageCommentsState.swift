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
    typealias Item = MediumCommentsQuery.Data.Medium.Comment.Item
    
    var currentUser: UserDetailFragment?

    var medium: RankedMediaQuery.Data.RankedMedium.Item
    var next: MediumCommentsQuery
    var items: [Item]
    var error: Error?
    var trigger: Bool
    
    var nextSaveComment: SaveCommentMutation
    var saveComment: SaveCommentMutation.Data.SaveComment?
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
    static func empty(medium: RankedMediaQuery.Data.RankedMedium.Item) -> ImageCommentsState {
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
        case onGetSuccess(MediumCommentsQuery.Data.Medium)
        case onGetError(Error)
        case onTriggerSaveComment
        case onSaveCommentSuccess(SaveCommentMutation.Data.SaveComment)
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
                $0.next.cursor = data.comments.cursor
                $0.items += data.comments.items.flatMap { $0 }
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
                let newCommet = Item(snapshot: data.snapshot)
                $0.items.insert(newCommet, at: 0)
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


