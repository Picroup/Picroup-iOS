//
//  Moment.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct Moment {
    
    static func string(from time: TimeInterval?) -> String {
        guard time != nil else { return " " }
        let remain = Date(timeIntervalSince1970: time!).timeIntervalSinceNow
        switch remain {
        case (1.0.weeks..<TimeInterval.infinity):
            return "\(Int(remain/1.0.weeks)) 周"
        case (1.0.days..<1.0.weeks):
            return "\(Int(remain/1.0.days)) 天"
        case (1.0.hours..<1.0.days):
            return "\(Int(remain/1.0.hours)) 小时"
        case (1.0.minutes..<1.0.hours):
            return "\(Int(remain/1.0.minutes)) 分钟"
        case (0..<1.0.minutes):
            return "\(Int(remain)) 秒"
        case ((-1.0.minutes)..<0):
            return "\(Int(-remain)) 秒前"
        case ((-1.0.hours)..<(-1.0.minutes)):
            return "\(Int(-remain/1.0.minutes)) 分钟前"
        case ((-1.0.days)..<(-1.0.hours)):
            return "\(Int(-remain/1.0.hours)) 小时前"
        case ((-1.0.weeks)..<(-1.0.days)):
            return "\(Int(-remain/1.0.days)) 天前"
        case ((-TimeInterval.infinity)..<(-1.0.weeks)):
            return "\(Int(-remain/1.0.weeks)) 周前"
        default:
            return " "
        }
    }
}
