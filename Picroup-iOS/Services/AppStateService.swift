//
//  AppStateService.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxFeedback
import Apollo

final class AppStateService {
    
    let appStore: AppStateStore?
    let events = PublishRelay<AppStateObject.Event>()
    fileprivate typealias Feedback = (Driver<AppStateObject>) -> Signal<AppStateObject.Event>
    
    init() {
        appStore = try? AppStateStore()
    }
    
    func setupRxfeedback() {
        
        guard let store = appStore else { return }
        
        let bindMe: Feedback = bind(self) { (me, state) in
            let subscriptions: [Disposable] = [
                ]
            let events: [Signal<AppStateObject.Event>] = [
                .just(.onTriggerReloadMe),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMe: Feedback = react(query: { $0.meQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.fragments.userDetailFragment }.unwrap()
                .map(AppStateObject.Event.onGetMeSuccess)
                .asSignal(onErrorReturnJust: AppStateObject.Event.onGetMeError)
        }
        
        let queryRecommendMedium: Feedback = react(query: { $0.recommendMediumQuery }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { _ in AppStateObject.Event.onRecommendMediumCompleted }
                .asSignal(onErrorJustReturn: AppStateObject.Event.onRecommendMediumCompleted)
        }
        
        let states = store.states
        
        _ = Signal.merge(
            bindMe(states),
            queryMe(states),
            queryRecommendMedium(states),
            events.asSignal()
            )
            .debug("AppState.Event", trimOutput: true)
            .emit(onNext: store.on)
    }
}
