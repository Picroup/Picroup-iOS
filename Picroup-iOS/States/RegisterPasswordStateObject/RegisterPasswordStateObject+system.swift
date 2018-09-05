//
//  RegisterPasswordStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension RegisterPasswordStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryValidPassword: @escaping (String) -> Single<Void>
        ) -> Driver<RegisterPasswordStateObject> {
        
        let queryValidPasswordFeedback: DriverFeedback = react(query: { $0.validPasswordQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryValidPassword(query)
                .map { .onValidPasswordSuccess }
                .asSignal(onErrorReturnJust: Event.onValidPasswordError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryValidPasswordFeedback],
            //            composeStates: { $0.debug("RegisterPasswordState", trimOutput: false) },
            composeEvents: { $0.debug("RegisterPasswordState.Event", trimOutput: true) }
        )
    }
}
