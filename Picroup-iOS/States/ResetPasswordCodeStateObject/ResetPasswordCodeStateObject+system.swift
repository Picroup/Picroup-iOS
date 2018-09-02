//
//  ResetPasswordCodeStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension ResetPasswordCodeStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        getVerifyCode: @escaping (GetVerifyCodeMutation) -> Single<String>,
        queryValidCode: @escaping (Double) -> Single<Void>,
        verifyCode: @escaping (VerifyCodeQuery) -> Single<String>
        ) -> Driver<ResetPasswordCodeStateObject> {
        
        let getVerifyCodeFeedback: DriverFeedback = react(query: { $0.getVerifyCodeQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return getVerifyCode(query)
                .map(Event.onGetVerifyCodeSuccess)
                .asSignal(onErrorReturnJust: Event.onGetVerifyCodeError)
        })
        
        let queryValidCodeFeedback: DriverFeedback = react(query: { $0.codeValidQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryValidCode(query)
                .map { .onValidCodeSuccess }
                .asSignal(onErrorReturnJust: Event.onValidCodeError)
        })
        
        let verifyCodeFeedback: DriverFeedback = react(query: { $0.verifyCodeQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return verifyCode(query)
                .map(Event.onVerifySuccess)
                .asSignal(onErrorReturnJust: Event.onVerifyError)
        })
        
        return system(
            feedbacks: [uiFeedback, getVerifyCodeFeedback, queryValidCodeFeedback, verifyCodeFeedback],
            //                        composeStates: { $0.debug("ResetPasswordCodeState", trimOutput: false) },
            composeEvents: { $0.debug("ResetPasswordCodeState.Event", trimOutput: true) }
        )
    }
}
