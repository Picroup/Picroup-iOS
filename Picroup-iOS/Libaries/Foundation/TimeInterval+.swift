//
//  TimeInterval+.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/18.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    var sinceNow: TimeInterval {
        return self - Date().timeIntervalSince1970
    }
}

extension TimeInterval {
    var minutes: TimeInterval { return self * 60 }
    var hours: TimeInterval { return self * 60.0.minutes }
    var days: TimeInterval { return self * 24.0.hours }
    var weeks: TimeInterval { return self * 7.0.days }
}

