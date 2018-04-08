//
//  Timed.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/7.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

public struct Timed<T> {
    public let time: TimeInterval
    public let value: T
    
    init(_ value: T) {
        self.time = Date().timeIntervalSince1970
        self.value = value
    }
}
