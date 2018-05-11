//
//  ImageDetailState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct ImageDetailState: Mutabled {
    typealias Meduim = QueryState<MediumQuery, MediumQuery.Data.Medium>
    typealias StarMedium = QueryState<StarMediumMutation, StarMediumMutation.Data.StarMedium>
    
    var currentUser: UserDetailFragment?
    
    var item: MediumFragment
    
    var next: MediumQuery
    var meduim: MediumQuery.Data.Medium?
    var items: [MediumFragment]
    var error: Error?
    var trigger: Bool
    
    var nextStarMedium: StarMediumMutation
    var starMedium: StarMediumMutation.Data.StarMedium?
    var starMediumError: Error?
    var triggerStarMedium: Bool
    
    var triggerShowComments: Bool
    var triggerShowUser: Bool
    
    var popQuery: Void?
}

extension ImageDetailState {
    public var query: MediumQuery? {
        if (currentUser == nil) { return nil }
        return trigger ? next : nil
    }
    var shouldQueryMore: Bool {
        return !trigger && next.cursor != nil
    }
    public var shouldStarMedium: Bool {
        return starMedium == nil && !triggerStarMedium
    }
    
    public var starMediumQuery: StarMediumMutation? {
        if (currentUser == nil) { return nil }
        return triggerStarMedium ? nextStarMedium : nil
    }
    
    public var showCommentsQuery: MediumFragment? {
        return triggerShowComments ? item : nil
    }
    
    public var showUserQuery: (isMe: Bool, user: UserFragment)? {
        if !triggerShowUser { return nil }
        let user = item.user.fragments.userFragment
        let isMe = currentUser?.id == user.id
        return (isMe, user)
    }
}

extension ImageDetailState {
    static func empty(item: MediumFragment) -> ImageDetailState {
        return ImageDetailState(
            currentUser: nil,
            item: item,
            next: MediumQuery(userId: "", mediumId: item.id),
            meduim: nil,
            items: [],
            error: nil,
            trigger: true,
            nextStarMedium: StarMediumMutation(userId: "", mediumId: item.id),
            starMedium: nil,
            starMediumError: nil,
            triggerStarMedium: false,
            triggerShowComments: false,
            triggerShowUser: false,
            popQuery: nil
        )
    }
}

extension ImageDetailState: IsFeedbackState {
    
    enum Event {
        case onUpdateCurrentUser(UserDetailFragment?)
        case onTriggerGet
        case onTriggerGetMore
        case onGetSuccess(MediumQuery.Data.Medium)
        case onGetError(Error)
        case onTriggerStarMedium
        case onStarMediumSuccess(StarMediumMutation.Data.StarMedium)
        case onStarMediumError(Error)
        
        case onTriggerShowComments
        case onShowCommentsCompleted
        
        case onTriggerShowUser
        case onShowUserCompleted
        
        case onPop
    }
}

extension ImageDetailState {
    
    static func reduce(state: ImageDetailState, event: Event) -> ImageDetailState {
        switch event {
        case .onUpdateCurrentUser(let currentUser):
            return state.mutated {
                $0.currentUser = currentUser
                $0.next.userId = currentUser?.id ?? ""
                $0.nextStarMedium.userId = currentUser?.id ?? ""
            }
        case .onTriggerGet:
            return state.mutated {
                $0.meduim = nil
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
                $0.next.cursor = data.recommendedMedia.cursor
                $0.meduim = data
                $0.items += data.recommendedMedia.fragments.cursorMediaFragment.items.flatMap { $0?.fragments.mediumFragment }
                $0.error = nil
                $0.trigger = false
            }
        case .onGetError(let error):
            return state.mutated {
                $0.meduim = nil
                $0.error = error
                $0.trigger = false
            }
        case .onTriggerStarMedium:
            return state.mutated {
                $0.starMedium = nil
                $0.starMediumError = nil
                $0.triggerStarMedium = true
            }
        case .onStarMediumSuccess(let data):
            return state.mutated {
                $0.starMedium = data
                $0.starMediumError = nil
                $0.triggerStarMedium = false
            }
        case .onStarMediumError(let error):
            return state.mutated {
                $0.starMedium = nil
                $0.starMediumError = error
                $0.triggerStarMedium = false
            }
        case .onTriggerShowComments:
            return state.mutated {
                $0.triggerShowComments = true
            }
        case .onShowCommentsCompleted:
            return state.mutated {
                $0.triggerShowComments = false
            }
        case .onTriggerShowUser:
            return state.mutated {
                $0.triggerShowUser = true
            }
        case .onShowUserCompleted:
            return state.mutated {
                $0.triggerShowUser = false
            }
        case .onPop:
            return state.mutated {
                $0.popQuery = ()
            }
        }
    }
}

