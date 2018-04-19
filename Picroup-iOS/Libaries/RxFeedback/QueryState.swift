//
//  QueryState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

public struct QueryState<Query, Data>: Mutabled {
    public var next: Query
    public var data: Data?
    public var error: Error?
    public var trigger: Bool
}

extension QueryState {
    public var query: Query? {
        return trigger ? next : nil
    }
    
    public init(next: Query, trigger: Bool = false) {
        self.next = next
        self.trigger = trigger
    }
}

extension QueryState: IsFeedbackState {
    
    public enum Event {
        case trigger
        case onSuccess(Data)
        case onError(Error)
    }
}

extension QueryState {
    
    public static func reduce(state: QueryState<Query, Data>, event: QueryState<Query, Data>.Event) -> QueryState<Query, Data> {
        switch event {
        case .trigger:
            return state.mutated {
                $0.data = nil
                $0.error = nil
                $0.trigger = true
            }
        case .onSuccess(let data):
            return state.mutated {
                $0.data = data
                $0.error = nil
                $0.trigger = false
            }
        case .onError(let error):
            return state.mutated {
                $0.data = nil
                $0.error = error
                $0.trigger = false
            }
        }
    }
}

