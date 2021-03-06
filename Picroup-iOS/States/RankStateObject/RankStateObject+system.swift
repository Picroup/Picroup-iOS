//
//  RankStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension RankStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryMedia: @escaping (HotMediaByTagsQuery) -> Single<CursorMediaFragment>,
        starMedium: @escaping (StarMediumMutation) -> Single<StarMediumMutation.Data.StarMedium>
        ) -> Driver<RankStateObject> {
        
        let queryMediaFeedback: DriverFeedback = react(query: { $0.hotMediaQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryMedia(query)
                .map(Event.onGetHotMediaData)
                .asSignal(onErrorReturnJust: Event.onGetHotMediaError)
        })
        
        let starMediumFeedback: DriverFeedback = react(query: { $0.starMediumQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return starMedium(query)
                .map(Event.onStarMediumSuccess)
                .asSignal(onErrorReturnJust: Event.onStarMediumError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryMediaFeedback, starMediumFeedback],
//            composeStates: { $0.debug("RankState", trimOutput: false) },
            composeEvents: { $0.debug("RankState.Event", trimOutput: true) }
        )
    }
}
