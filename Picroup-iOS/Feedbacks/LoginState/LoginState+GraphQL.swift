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
        return react(query: { $0.query }) { query in
            return client.rx.fetch(query: query)
                .map { $0?.data?.login?.fragments.userDetailFragment }.map {
                    guard let userDetailFragment = $0 else { throw LoginError.usernameOrPasswordIncorrect }
                    return userDetailFragment
                }
                .map(LoginState.Event.onSuccess)
                .asSignal(onErrorReturnJust: LoginState.Event.onError)
        }
    }
}
