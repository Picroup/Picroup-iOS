//
//  HomeState+GraphQL.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == HomeState {
    
    static func queryMedia(client: ApolloClient) -> Raw {
        return react(query: { $0.query }) { query in
            client.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user }.unwrap()
                .map(HomeState.Event.onGetSuccess)
                .asSignal(onErrorReturnJust: { .onGetError($0) })
        }
    }
}

