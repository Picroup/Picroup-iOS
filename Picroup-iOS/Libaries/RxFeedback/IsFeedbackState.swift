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
