//
//  LoginState+drive.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == LoginState {
    
    static func system(client: ApolloClient, store: AppStore) -> (@escaping DriverFeedback<LoginState>.Raw) -> Disposable {
        
        return { uiFeedback in
            let syncState = self.syncState(store: store)
            let queryLogin = self.queryLogin(client: client)
            return Driver<Any>.system(
                initialState: LoginState.empty,
                reduce: logger(identifier: "LoginState")(LoginState.reduce),
                feedback: syncState, uiFeedback, queryLogin
                ).drive()
        }
    }
}
