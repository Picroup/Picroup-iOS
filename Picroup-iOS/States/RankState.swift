//
//  RankState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/12.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct RankState: Mutabled {
    var rankedMediaQuery: RankedMediaQuery
    var items: [RankedMediaQuery.Data.RankedMedium.Item]
    var shouldGetMedia: Bool
}

extension RankState {
    var isGettingMedia: Bool { return shouldGetMedia }
    var triggerGetMedia: RankedMediaQuery? {
        return shouldGetMedia ? rankedMediaQuery : nil
    }
    var shouldGetMore: Bool {
        return !isGettingMedia && rankedMediaQuery.cusor != nil
    }
}

extension RankState {
    static var empty: RankState {
        return RankState(
            rankedMediaQuery: RankedMediaQuery(),
            items: [],
            shouldGetMedia: true
        )
    }
}

extension RankState: IsFeedbackState {
    enum Event {
        case onChangeCategory(MediumCategory?)
        case onTriggerGetMore
    }
}

extension RankState {
    
    static func reduce(state: RankState, event: RankState.Event) -> RankState {
        switch event {
        case .onChangeCategory(let category):
            return state.mutated {
                $0.rankedMediaQuery.category = category
                $0.rankedMediaQuery.cusor = nil
                $0.items = []
                $0.shouldGetMedia = true
            }
        case .onTriggerGetMore:
            guard state.shouldGetMore else { return state }
            return state.mutated {
                $0.shouldGetMedia = true
            }
        }
    }
}

