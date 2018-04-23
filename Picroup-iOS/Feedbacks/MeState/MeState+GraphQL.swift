//
//  MeState+GraphQL.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == MeState {
    
    static func queryMe(client: ApolloClient) -> Raw {
        return react(query: { $0.me.query }) { query in
            client.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user }.unwrap()
                .map { .me(.onSuccess($0)) }
                .asSignal(onErrorReturnJust: { .me(.onError($0)) })
        }
    }
    
    static func queryMyMedia(client: ApolloClient) -> Raw {
        return react(query: { $0.myMediaQuery }) { query in
            client.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.media }.unwrap()
                .map(MeState.Event.onGetSuccess)
                .asSignal(onErrorReturnJust: { .onGetError($0) })
        }
    }
}
