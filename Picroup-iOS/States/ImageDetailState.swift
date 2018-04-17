//
//  ImageDetailState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct ImageDetailState: Mutabled {
    let userId: String
    var medium: RankedMediaQuery.Data.RankedMedium.Item
    var meduimState: QueryState<MediumQuery, MediumQuery.Data.Medium>
    var staredMediumState: QueryState<StarMediumMutation, StarMediumMutation.Data.StarMedium>
}

extension ImageDetailState {
    static func empty(userId: String, medium: RankedMediaQuery.Data.RankedMedium.Item) -> ImageDetailState {
        return ImageDetailState(
            userId: userId,
            medium: medium,
            meduimState: QueryState(
                next: MediumQuery(userId: userId, mediumId: medium.id),
                trigger: true
            ),
            staredMediumState: QueryState(
                next: StarMediumMutation(userId: userId, mediumId: medium.id),
                trigger: false
            )
        )
    }
}

extension ImageDetailState: IsFeedbackState {
    
    enum Event {
        case onQuerySuccess(MediumQuery.Data.Medium)
        case onQueryError(Error)
        
    }
}

extension ImageDetailState {
    
    static func reduce(state: ImageDetailState, event: Event) -> ImageDetailState {
        switch event {
        case .onQuerySuccess(let queriedMedium):
            return state.mutated {
                $0.meduimState -= .onSuccess(queriedMedium)
            }
        case .onQueryError(let error):
            return state.mutated {
                $0.meduimState -= .onError(error)
            }
        }
    }
}
