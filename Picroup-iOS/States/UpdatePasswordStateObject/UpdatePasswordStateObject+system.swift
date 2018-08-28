//
//  UpdatePasswordStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension UpdatePasswordStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        querySetPassword: @escaping (UserSetPasswordQuery) -> Single<UserFragment>
        ) -> Disposable {
        
        let querySetPasswordFeedback: DriverFeedback = react(query: { $0.setPasswordQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return querySetPassword(query)
                .map(Event.onSetPasswordSuccess)
                .asSignal(onErrorReturnJust: Event.onSetPasswordError)
        })
        
        return system(
            feedbacks: [uiFeedback, querySetPasswordFeedback],
//            composeStates: { $0.debug("UpdatePasswordState", trimOutput: false) },
            composeEvents: { $0.debug("UpdatePasswordState.Event", trimOutput: true) }
        )
    }
}
