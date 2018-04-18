//
//  TimeInterval+days.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/18.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    var weeks: TimeInterval {
        return self * 7 * 24 * 3600
    }
    
    var days: TimeInterval {
        return self * 24 * 3600
    }
    
    var hours: TimeInterval {
        return self * 3600
    }
}

