//
//  HomeStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension HomeStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryMyInterestedMedia: @escaping (UserInterestedMediaQuery) -> Single<CursorMediaFragment>,
        starMedium: @escaping (StarMediumMutation) -> Single<StarMediumMutation.Data.StarMedium>
        ) -> Driver<HomeStateObject> {
        
        let queryMyInterestedMediaFeedback: DriverFeedback = react(query: { $0.myInterestedMediaQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
             return queryMyInterestedMedia(query)
                .map(Event.onGetMyInterestedMediaData)
                .asSignal(onErrorReturnJust: (Event.onGetMyInterestedMediaError))
        })
        
        let starMediumFeedback: DriverFeedback = react(query: { $0.starMediumQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return starMedium(query)
                .map(Event.onStarMediumSuccess)
                .asSignal(onErrorReturnJust: Event.onStarMediumError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryMyInterestedMediaFeedback, starMediumFeedback],
            //            composeStates: { $0.debug("HomeState", trimOutput: false) },
            composeEvents: { $0.debug("HomeState.Event", trimOutput: true) }
        )
    }
}

