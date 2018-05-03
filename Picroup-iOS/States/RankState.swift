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
        return !triggerQueryMedia && nextRankedMediaQuery.cursor != nil
    }
    var isItemsEmpty: Bool {
        return !triggerQueryMedia && error == nil && items.isEmpty
    }
    var hasMore: Bool {
        return nextRankedMediaQuery.cursor != nil
    }
}

extension RankState {
    static func empty() -> RankState {
        return RankState(
            nextRankedMediaQuery: RankedMediaQuery(rankBy: .thisMonth),
            items: [],
            error: nil,
            triggerQueryMedia: true
        )
    }
}

extension RankState: IsFeedbackState {
    enum Event {
        case onChangeRankBy(RankBy?)
        case onTriggerGetMore
        case onGetSuccess(RankedMediaQuery.Data.RankedMedium)
        case onGetError(Error)
    }
}

extension RankState {
    
    static func reduce(state: RankState, event: RankState.Event) -> RankState {
        switch event {
        case .onChangeRankBy(let rankBy):
            return state.mutated {
                $0.nextRankedMediaQuery.rankBy = rankBy
                $0.nextRankedMediaQuery.cursor = nil
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
                $0.nextRankedMediaQuery.cursor = data.cursor
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
        return lhs.rankBy == rhs.rankBy
            && lhs.cursor == rhs.cursor
    }
}


