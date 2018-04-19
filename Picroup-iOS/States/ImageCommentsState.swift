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

    let userId: String
    var medium: RankedMediaQuery.Data.RankedMedium.Item
    var next: MediumCommentsQuery
    var items: [MediumCommentsQuery.Data.Medium.Comment.Item]
    var error: Error?
    var trigger: Bool
    
    var saveComment: SaveComment
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
        return !saveComment.trigger && !saveComment.next.content.isEmpty
    }
}

extension ImageCommentsState {
    static func empty(userId: String, medium: RankedMediaQuery.Data.RankedMedium.Item) -> ImageCommentsState {
        return ImageCommentsState(
            userId: userId,
            medium: medium,
            next: MediumCommentsQuery(
                mediumId: medium.id,
                cursor: nil
            ),
            items: [],
            error: nil,
            trigger: true,
            saveComment: SaveComment(
                next: SaveCommentMutation(userId: userId, mediumId: medium.id, content: "")
            )
        )
    }
}

extension ImageCommentsState: IsFeedbackState {
    enum Event {
        case onTriggerReload
        case onTriggerGetMore
        case onGetSuccess(MediumCommentsQuery.Data.Medium)
        case onGetError(Error)
        case saveComment(SaveComment.Event)
        case onChangeCommentContent(String)
    }
}

extension ImageCommentsState {
    
    static func reduce(state: ImageCommentsState, event: ImageCommentsState.Event) -> ImageCommentsState {
        switch event {
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
        case .saveComment(let event):
            return state.mutated {
                $0.saveComment -= event
                if case .onSuccess = event {
                    $0.saveComment.next.content = ""
                }
            }
        case .onChangeCommentContent(let content):
            return state.mutated {
                $0.saveComment.next.content = content
            }
        }
    }
    
}


