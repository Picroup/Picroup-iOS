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
    
    private let _appStore: AppStateStore?
    let events = PublishRelay<AppStateObject.Event>()
    fileprivate typealias Feedback = (Driver<AppStateObject>) -> Signal<AppStateObject.Event>
    
    init() {
        _appStore = try? AppStateStore()
    }
    
    func setupRxfeedback() {
        guard let store = _appStore else { return }
        
        let queryRecommendMedium: Feedback = react(query: { $0.recommendMediumQuery }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { _ in AppStateObject.Event.onRecommendMediumCompleted }
                .asSignal(onErrorJustReturn: AppStateObject.Event.onRecommendMediumCompleted)
        }
        
        let states = store.states
        
        _ = Signal.merge(
            queryRecommendMedium(states),
            events.asSignal()
            )
            .debug("AppState.Event", trimOutput: true)
            .emit(onNext: store.on)
    }
}
