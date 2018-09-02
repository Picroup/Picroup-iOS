//
//  ResetPasswordStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension ResetPasswordStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryValidPassword: @escaping (String) -> Single<Void>,
        resetPassword: @escaping (ResetPasswordMutation) -> Single<String>,
        confirmResetPasswordSuccess: @escaping (String) -> Observable<Void>
        ) -> Driver<ResetPasswordStateObject> {
        
        let queryValidPasswordFeedback: DriverFeedback = react(query: { $0.validPasswordQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryValidPassword(query)
                .map { .onValidPasswordSuccess }
                .asSignal(onErrorReturnJust: Event.onValidPasswordError)
        })
        
        let resetPasswordFeedback: DriverFeedback = react(query: { $0.resetPasswordQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return resetPassword(query)
                .map(Event.onResetPasswordSuccess)
                .asSignal(onErrorReturnJust: Event.onResetPasswordError)
        })
        
        let confirmResetPasswordSuccessFeedback: DriverFeedback = react(query: { $0.username }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return confirmResetPasswordSuccess(query)
                .map { .onConfirmResetPasswordSuccess }
                .asSignalOnErrorRecoverEmpty()
        })
        
        return system(
            feedbacks: [uiFeedback, queryValidPasswordFeedback, resetPasswordFeedback, confirmResetPasswordSuccessFeedback],
            //                        composeStates: { $0.debug("ResetPasswordState", trimOutput: false) },
            composeEvents: { $0.debug("ResetPasswordState.Event", trimOutput: true) }
        )
    }
}
