//
//  IsFeedbackStateObject+system.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/28.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

extension IsFeedbackStateObject where Self: VersionedPrimaryObject {
    
    typealias DriverFeedback = (Driver<Self>) -> Signal<Event>
    typealias ObservableFeedback = (Observable<Self>) -> Observable<Event>

    func system(
        feedbacks: [DriverFeedback],
        composeStates: (Driver<Self>) -> Driver<Self> = { $0 },
        composeEvents: (Signal<Event>) -> Signal<Event> = { $0 }
        ) -> Disposable {
        
        let states = Observable.from(object: self).asDriver(onErrorDriveWith: .empty())
        let composedStates = composeStates(states)
        let feedbackEvents = Signal.merge(feedbacks.map { $0(composedStates) })
        let composedEvents = composeEvents(feedbackEvents)
        return composedEvents
            .emit(to: events)
    }
    
    func system(
        feedbacks: [ObservableFeedback],
        composeStates: (Observable<Self>) -> Observable<Self> = { $0 },
        composeEvents: (Observable<Event>) -> Observable<Event> = { $0 }
        ) -> Disposable {
        
        let states = Observable.from(object: self)
        let composedStates = composeStates(states)
        let feedbackEvents = Observable.merge(feedbacks.map { $0(composedStates) })
        let composedEvents = composeEvents(feedbackEvents)
        return composedEvents
            .bind(to: events)
    }
    
    private var events: Binder<Event> {
        return Binder(self) { state, event in
            Realm.backgroundReduce(ofType: Self.self, forPrimaryKey: state._id, event: event)
        }
    }
}
