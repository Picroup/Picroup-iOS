//
//  NotificationsState+GraphQL.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/25.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == NotificationsState {
    
    static func queryNotifications(client: ApolloClient) -> Raw {
        return react(query: { $0.query }) { query in
            client.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.notifications }.unwrap()
                .map(NotificationsState.Event.onGetSuccess)
                .asSignal(onErrorReturnJust: NotificationsState.Event.onGetError)
        }
    }
    
    static func queryMarkNotificationsAsViewed(client: ApolloClient) -> Raw {
        return react(query: { $0.markQuery }) { query in
            client.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.markNotificationsAsViewed }.unwrap()
                .map(NotificationsState.Event.onMarkSuccess)
                .asSignal(onErrorReturnJust: NotificationsState.Event.onMarkError)
        }
    }
}
