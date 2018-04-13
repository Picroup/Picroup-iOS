//
//  connect.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/7.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift
import RxCocoa
import RxFeedback

func connect<ParentState, ParentEvent, ChildState, ChildEvent, Param>(
    keyed: @escaping (ParentState) -> Param?,
    mapParentStateToChildEvent: @escaping (Driver<ParentState>) -> Signal<ChildEvent> = { _ in .never() },
    mapChildStateToParentEvent: @escaping (Driver<ChildState>) -> Signal<ParentEvent> = { _ in .empty() },
    route: @escaping (Param, @escaping (Driver<ChildState>) -> Signal<ChildEvent>) -> Void
    ) -> (Driver<ParentState>) -> Signal<ParentEvent> {
    return { parentState in
        parentState.map(keyed).distinctUnwrap()
            .flatMap { param in
                let parentEvent = PublishRelay<ParentEvent>()
                let childFeedback: (Driver<ChildState>) -> Signal<ChildEvent> = bind { (childState) in
                    Bindings(subscriptions: [
                        mapChildStateToParentEvent(childState).emit(to: parentEvent)
                    ], events: [
                        mapParentStateToChildEvent(parentState)
                    ])
                }
                route(param, childFeedback)
                return parentEvent.asSignal()
                
        }
    }
}
