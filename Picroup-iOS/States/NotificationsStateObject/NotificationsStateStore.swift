//
//  NotificationsStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxFeedback

extension NotificationsStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryNotifacations: @escaping (MyNotificationsQuery) -> Single<CursorNotoficationsFragment>,
        queryMark: @escaping (MarkNotificationsAsViewedQuery) -> Single<String>
        ) -> Driver<NotificationsStateObject> {
        
        let queryNotifacationsFeedback: DriverFeedback = react(query: { $0.notificationsQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryNotifacations(query)
                .map(Event.onGetData)
                .asSignal(onErrorReturnJust: Event.onGetError)
        })
        
        let queryMarkFeedback: DriverFeedback = react(query: { $0.markQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryMark(query)
                .map(Event.onMarkSuccess)
                .asSignal(onErrorReturnJust: Event.onMarkError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryNotifacationsFeedback, queryMarkFeedback],
            //            composeStates: { $0.debug("NotificationsState", trimOutput: false) },
            composeEvents: { $0.debug("NotificationsState.Event", trimOutput: true) }
        )
    }
}
