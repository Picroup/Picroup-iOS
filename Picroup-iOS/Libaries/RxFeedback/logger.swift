//
//  Middleware.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

public typealias Reduce<State, Event> = (State, Event) -> State

public func logger<State, Event>(identifier: String? = nil)
    -> (@escaping Reduce<State, Event>) -> Reduce<State, Event> {
        return { reduce in { state, event in
//            let prefix = identifier.map { "\($0) " } ?? ""
//            print("\(prefix)event: \(event)\n")
            let newState = reduce(state, event)
//            print("\(prefix)state: \(newState)\n")
            return newState
        }}
}

