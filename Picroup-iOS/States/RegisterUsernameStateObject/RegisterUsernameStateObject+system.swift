//
//  RegisterUsernameStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension RegisterUsernameStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryIsRegisterUsernameAvailable: @escaping (String) -> Single<Void>
        ) -> Driver<RegisterUsernameStateObject> {
        
        let queryIsRegisterUsernameAvailableFeedback: DriverFeedback = react(query: { $0.usernameAvailableQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryIsRegisterUsernameAvailable(query)
                .map { .onUsernameAvailableSuccess }
                .asSignal(onErrorReturnJust: Event.onUsernameAvailableError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryIsRegisterUsernameAvailableFeedback],
            //            composeStates: { $0.debug("RegisterUsernameState", trimOutput: false) },
            composeEvents: { $0.debug("RegisterUsernameState.Event", trimOutput: true) }
        )
    }
}

