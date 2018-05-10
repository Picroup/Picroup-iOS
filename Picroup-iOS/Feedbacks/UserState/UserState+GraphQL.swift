//
//  UserState+GraphQL.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == UserState {
    
    static func queryUser(client: ApolloClient) -> Raw {
        return react(query: { $0.userQuery }) { query in
            client.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.fragments.userDetailFragment }.unwrap()
                .map(UserState.Event.onGetUserSuccess)
                .asSignal(onErrorReturnJust: UserState.Event.onGetUserError)
        }
    }
    
//    static func queryMyMedia(client: ApolloClient) -> Raw {
//        return react(query: { $0.myMediaQuery }) { query in
//            client.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
//                .map { $0?.data?.user?.media.fragments.cursorMediaFragment }.unwrap()
//                .map(MeState.Event.onGetMyMediaSuccess)
//                .asSignal(onErrorReturnJust: MeState.Event.onGetMyMediaError)
//        }
//    }
}
