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
        ) -> Driver<Self> {
        
        let observableFeedbacks: [ObservableFeedback] = {
            let transform: (@escaping DriverFeedback) -> ObservableFeedback = { driverFeedback in { observableState -> Observable<Event> in
                return driverFeedback(observableState.asDriver(onErrorDriveWith: Driver<Self>.empty())).asObservable()
                }}
            return feedbacks.map(transform)
        }()
        
        return system(
            feedbacks: observableFeedbacks,
            composeStates: { sourceState in
                return composeStates(sourceState.asDriver(onErrorDriveWith: Driver<Self>.empty())).asObservable()
        },
            composeEvents: { sourceEvent in
                return composeEvents(sourceEvent.asSignal(onErrorSignalWith: Signal<Event>.empty())).asObservable()
        })
            .asDriver(onErrorDriveWith: Driver<Self>.empty())
    }
    
    func system(
        feedbacks: [ObservableFeedback],
        composeStates: (Observable<Self>) -> Observable<Self> = { $0 },
        composeEvents: (Observable<Event>) -> Observable<Event> = { $0 }
        ) -> Observable<Self> {
        
        let states = rx.observe().share()
        let composedStates = composeStates(states)
        let feedbackEvents = Observable.merge(feedbacks.map { $0(composedStates) })
        let composedEvents = composeEvents(feedbackEvents)
        let events = self.events        
        return Observable<Self>.using({ () -> SingleAssignmentDisposable in
            let disposable = composedEvents.bind(to: events)
            return SingleAssignmentDisposable(disposable: disposable)
        }, observableFactory: { _ in composedStates })
    }
    
    private var events: Binder<Event> {
        return Binder(self) { state, event in
            Realm.backgroundReduce(ofType: Self.self, forPrimaryKey: state._id, event: event)
        }
    }
}

extension SingleAssignmentDisposable {
    
    convenience init(disposable: Disposable) {
        self.init()
        self.setDisposable(disposable)
    }
}
