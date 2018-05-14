//
//  ReputationsState+GraphQL.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == ReputationsState {
    
    static func queryReputations(client: ApolloClient) -> Raw {
        return react(query: { $0.query }) { query in
            client.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.reputationLinks.fragments.cursorReputationLinksFragment }.unwrap()
                .map(ReputationsState.Event.onGetSuccess)
                .asSignal(onErrorReturnJust: ReputationsState.Event.onGetError)
        }
    }
    
    static func queryMarkRepotationsAsViewed(client: ApolloClient) -> Raw {
        return react(query: { $0.markQuery }) { query in
            client.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.markReputationLinksAsViewed }.unwrap()
                .map(ReputationsState.Event.onMarkSuccess)
                .asSignal(onErrorReturnJust: ReputationsState.Event.onMarkError)
        }
    }
}
