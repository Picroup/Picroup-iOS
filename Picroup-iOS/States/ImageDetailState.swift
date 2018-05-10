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
    typealias Item = MediumQuery.Data.Medium.RecommendedMedium.Item
    
    var currentUser: UserDetailFragment?
    
    var item: RankedMediaQuery.Data.RankedMedium.Item
    
    var next: MediumQuery
    var meduim: MediumQuery.Data.Medium?
    var items: [Item]
    var error: Error?
    var trigger: Bool
    
    var nextStarMedium: StarMediumMutation
    var starMedium: StarMediumMutation.Data.StarMedium?
    var starMediumError: Error?
    var triggerStarMedium: Bool
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
}

extension ImageDetailState {
    static func empty(item: RankedMediaQuery.Data.RankedMedium.Item) -> ImageDetailState {
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
            triggerStarMedium: false
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
                $0.items += data.recommendedMedia.items.flatMap { $0 }
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
        }
    }
}

