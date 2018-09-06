//
//  ReputationsStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxFeedback

extension ReputationsStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryReputations: @escaping (MyReputationsQuery) -> Single<CursorReputationLinksFragment>,
        queryMark: @escaping (MarkReputationLinksAsViewedQuery) -> Single<String>
        ) -> Driver<ReputationsStateObject> {
        
        let queryReputationsFeedback: DriverFeedback = react(query: { $0.reputationsQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryReputations(query)
                .map(Event.onGetData)
                .asSignal(onErrorReturnJust: Event.onGetError)
        })
        
        let queryMarkFeedback: DriverFeedback = react(query: { $0.markQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryMark(query)
                .map(Event.onMarkSuccess)
                .asSignal(onErrorReturnJust: Event.onMarkError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryReputationsFeedback, queryMarkFeedback],
            //            composeStates: { $0.debug("ReputationsState", trimOutput: false) },
            composeEvents: { $0.debug("ReputationsState.Event", trimOutput: true) }
        )
    }
}
