//
//  MeStateStore.swift
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

extension MeStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryMyMedia: @escaping (MyMediaQuery) -> Single<CursorMediaFragment>,
        queryMyStaredMedia: @escaping (MyStaredMediaQuery) -> Single<CursorMediaFragment>
        ) -> Driver<MeStateObject> {
        
        let queryMyMediaMediaFeedback: DriverFeedback = react(query: { $0.myMediaQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryMyMedia(query)
                .map(Event.onGetMyMediaData)
                .asSignal(onErrorReturnJust: (Event.onGetMyMediaError))
        })
        
        let queryMyStaredMediaFeedback: DriverFeedback = react(query: { $0.myStaredMediaQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryMyStaredMedia(query)
                .map(Event.onGetMyStaredMediaData)
                .asSignal(onErrorReturnJust: (Event.onGetMyStaredMediaError))
        })
        
        return system(
            feedbacks: [uiFeedback, queryMyMediaMediaFeedback, queryMyStaredMediaFeedback],
            //            composeStates: { $0.debug("MeState", trimOutput: false) },
            composeEvents: { $0.debug("MeState.Event", trimOutput: true) }
        )
    }
}
