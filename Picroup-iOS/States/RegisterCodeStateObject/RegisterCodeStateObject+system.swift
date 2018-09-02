//
//  RegisterCodeStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension RegisterCodeStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        getVerifyCode: @escaping (GetVerifyCodeMutation) -> Single<String>,
        queryValidCode: @escaping (Double) -> Single<Void>,
        register: @escaping (RegisterMutation) -> Single<UserDetailFragment>
        ) -> Driver<RegisterCodeStateObject> {
        
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
        
        let registerFeedback: DriverFeedback = react(query: { $0.registerQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return register(query)
                .map(Event.onRegisterSuccess)
                .asSignal(onErrorReturnJust: Event.onRegisterError)
        })
        
        return system(
            feedbacks: [uiFeedback, getVerifyCodeFeedback, queryValidCodeFeedback, registerFeedback],
//                        composeStates: { $0.debug("RegisterCodeState", trimOutput: false) },
            composeEvents: { $0.debug("RegisterCodeState.Event", trimOutput: true) }
        )
    }
}
