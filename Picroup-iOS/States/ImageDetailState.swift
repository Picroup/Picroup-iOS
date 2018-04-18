//
//  ImageDetailState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct ImageDetailState: Mutabled {
    typealias MeduimState = QueryState<MediumQuery, MediumQuery.Data.Medium>
    typealias StaredMediumState = QueryState<StarMediumMutation, StarMediumMutation.Data.StarMedium>
    
    let userId: String
    var item: RankedMediaQuery.Data.RankedMedium.Item
    var meduim: MeduimState
    var staredMedium: StaredMediumState
}

extension ImageDetailState {
    static func empty(userId: String, item: RankedMediaQuery.Data.RankedMedium.Item) -> ImageDetailState {
        return ImageDetailState(
            userId: userId,
            item: item,
            meduim: QueryState(
                next: MediumQuery(userId: userId, mediumId: item.id),
                trigger: true
            ),
            staredMedium: QueryState(
                next: StarMediumMutation(userId: userId, mediumId: item.id),
                trigger: false
            )
        )
    }
}

extension ImageDetailState: IsFeedbackState {
    
    enum Event {
        case meduim(MeduimState.Event)
        case staredMedium(StaredMediumState.Event)
    }
}

extension ImageDetailState {
    
    static func reduce(state: ImageDetailState, event: Event) -> ImageDetailState {
        switch event {
        case .meduim(let event):
            return state.mutated {
                $0.meduim -= event
            }
        case .staredMedium(let event):
            return state.mutated {
                $0.staredMedium -= event
            }
        }
    }
}

