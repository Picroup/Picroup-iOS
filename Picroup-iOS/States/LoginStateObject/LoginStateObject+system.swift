//
//  LoginStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension LoginStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryLogin: @escaping (LoginQuery) -> Single<UserDetailFragment>
        ) -> Disposable {
        
        let queryLoginFeedback: DriverFeedback = react(query: { $0.loginQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryLogin(query)
                .map(Event.onLoginSuccess)
                .asSignal(onErrorReturnJust: Event.onLoginError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryLoginFeedback],
//            composeStates: { $0.debug("LoginState", trimOutput: false) },
            composeEvents: { $0.debug("LoginState.Event", trimOutput: true) }
        )
    }
}
