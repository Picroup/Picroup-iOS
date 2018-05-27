//
//  IsFeedbackState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

public protocol IsFeedbackState {
    associatedtype Event
    static func reduce(state: Self, event: Event) -> Self
}

public func -=<S>(lhs: inout S, rhs: S.Event) where S: IsFeedbackState {
    lhs = S.reduce(state: lhs, event: rhs)
}

public func -<S>(lhs: S, rhs: S.Event) -> S where S: IsFeedbackState {
    return S.reduce(state: lhs, event: rhs)
}

