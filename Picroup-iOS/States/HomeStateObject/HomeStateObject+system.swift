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
        queryMyInterestedMedia: @escaping (UserInterestedMediaQuery) -> Single<CursorMediaFragment>
        ) -> Disposable {
        
        let queryMyInterestedMediaFeedback: DriverFeedback = react(query: { $0.myInterestedMediaQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
             return queryMyInterestedMedia(query)
                .map(Event.onGetMyInterestedMediaData)
                .asSignal(onErrorReturnJust: (Event.onGetMyInterestedMediaError))
        })
        
        return system(
            feedbacks: [uiFeedback, queryMyInterestedMediaFeedback],
            //            composeStates: { $0.debug("HomeState", trimOutput: false) },
            composeEvents: { $0.debug("HomeState.Event", trimOutput: true) }
        )
    }
}

