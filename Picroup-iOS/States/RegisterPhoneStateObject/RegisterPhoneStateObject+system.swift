//
//  RegisterPhoneStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension RegisterPhoneStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryIsRegisterPhoneNumberAvailable: @escaping (String) -> Single<Void>
        ) -> Driver<RegisterPhoneStateObject> {
        
        let queryIsRegisterPhoneNumberAvailableFeedback: DriverFeedback = react(query: { $0.phoneNumberAvailableQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryIsRegisterPhoneNumberAvailable(query)
                .map { .onPhoneNumberAvailableSuccess }
                .asSignal(onErrorReturnJust: Event.onPhoneNumberAvailableError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryIsRegisterPhoneNumberAvailableFeedback],
            //            composeStates: { $0.debug("RegisterPhoneState", trimOutput: false) },
            composeEvents: { $0.debug("RegisterPhoneState.Event", trimOutput: true) }
        )
    }
}
