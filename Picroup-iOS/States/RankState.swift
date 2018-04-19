//
//  RankState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/12.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct RankState: Mutabled {
    var nextRankedMediaQuery: RankedMediaQuery
    var items: [RankedMediaQuery.Data.RankedMedium.Item]
    var error: Error?
    var triggerQueryMedia: Bool
}

extension RankState {
    var rankedMediaQuery: RankedMediaQuery? {
        return triggerQueryMedia ? nextRankedMediaQuery : nil
    }
    var shouldQueryMore: Bool {
        return !triggerQueryMedia && nextRankedMediaQuery.cusor != nil
    }
    var isItemsEmpty: Bool {
        return !triggerQueryMedia && error == nil && items.isEmpty
    }
    var hasMore: Bool {
        return nextRankedMediaQuery.cusor != nil
    }
}

extension RankState {
    static func empty(selectedCategory: MediumCategory?) -> RankState {
        return RankState(
            nextRankedMediaQuery: RankedMediaQuery(category: selectedCategory),
            items: [],
            error: nil,
            triggerQueryMedia: true
        )
    }
}

extension RankState: IsFeedbackState {
    enum Event {
        case onChangeCategory(MediumCategory?)
        case onChangeRankBy(RankBy?)
        case onTriggerGetMore
        case onGetSuccess(RankedMediaQuery.Data.RankedMedium)
        case onGetError(Error)
    }
}

extension RankState {
    
    static func reduce(state: RankState, event: RankState.Event) -> RankState {
        switch event {
        case .onChangeCategory(let category):
            return state.mutated {
                $0.nextRankedMediaQuery.category = category
                $0.nextRankedMediaQuery.cusor = nil
                $0.items = []
                $0.error = nil
                $0.triggerQueryMedia = true
            }
        case .onChangeRankBy(let rankBy):
            return state.mutated {
                $0.nextRankedMediaQuery.rankBy = rankBy
                $0.nextRankedMediaQuery.cusor = nil
                $0.items = []
                $0.error = nil
                $0.triggerQueryMedia = true
            }
        case .onTriggerGetMore:
            guard state.shouldQueryMore else { return state }
            return state.mutated {
                $0.error = nil
                $0.triggerQueryMedia = true
            }
        case .onGetSuccess(let data):
            return state.mutated {
                $0.nextRankedMediaQuery.cusor = data.cursor
                $0.items += data.items.flatMap { $0 }
                $0.error = nil
                $0.triggerQueryMedia = false
            }
        case .onGetError(let error):
            return state.mutated {
                $0.error = error
                $0.triggerQueryMedia = false
            }
        }
    }
}

extension RankedMediaQuery: Equatable {
    
    public static func ==(lhs: RankedMediaQuery, rhs: RankedMediaQuery) -> Bool {
        return lhs.category == rhs.category
            && lhs.rankBy == rhs.rankBy
            && lhs.cusor == rhs.cusor
    }
}


