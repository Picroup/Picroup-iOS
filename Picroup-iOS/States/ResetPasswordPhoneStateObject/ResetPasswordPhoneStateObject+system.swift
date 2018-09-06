//
//  ResetPasswordPhoneStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension ResetPasswordPhoneStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryIsResetPhoneNumberAvailable: @escaping (String) -> Single<Void>
        ) -> Driver<ResetPasswordPhoneStateObject> {
        
        let queryIsResetPhoneNumberAvailableFeedback: DriverFeedback = react(query: { $0.phoneNumberAvailableQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryIsResetPhoneNumberAvailable(query)
                .map { .onPhoneNumberAvailableSuccess }
                .asSignal(onErrorReturnJust: Event.onPhoneNumberAvailableError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryIsResetPhoneNumberAvailableFeedback],
            //            composeStates: { $0.debug("ResetPasswordPhoneState", trimOutput: false) },
            composeEvents: { $0.debug("ResetPasswordPhoneState.Event", trimOutput: true) }
        )
    }
}
