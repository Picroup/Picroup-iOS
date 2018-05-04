//
//  LoginState+GraphQL.swift
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
    
    static func queryLogin(client: ApolloClient) -> Raw {
        return react(query: { $0.triggerLogin }) { [client] param in
            let (username, password) = param
            return client.rx.fetch(query: LoginQuery(username: username, password: password))
                .map { $0?.data?.login }.map {
                    guard let snapshot = $0?.snapshot else { throw LoginError.usernameOrPasswordIncorrect }
                    return UserQuery.Data.User(snapshot: snapshot)
                }
                .map(LoginState.Event.onSuccess)
                .asSignal(onErrorReturnJust: LoginState.Event.onError)
        }
    }
}
