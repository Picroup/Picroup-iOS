//
//  Mutabled.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

protocol Mutabled {
    func mutated(_ mutation: (inout Self) -> Void) -> Self
}

extension Mutabled {
    
    func mutated(_ mutation: (inout Self) -> Void) -> Self {
        var newValue = self
        mutation(&newValue)
        return newValue
    }
}
