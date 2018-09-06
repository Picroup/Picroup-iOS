//
//  LoadFooterViewState+create.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

extension LoadFooterViewState {
    
    static func create<T>(cursor: Double?, items: List<T>?, trigger: Bool, error: String?) -> LoadFooterViewState {
        if cursor == nil && trigger {
            return .empty
        }
        if error != nil {
            return .message("💁🏻‍♀️ 加载失败，请重试")
        }
        if cursor != nil && trigger {
            return .loading
        }
//        if cursor == nil && !trigger && items?.isEmpty == false {
//            return .message("🙆🏻‍♀️")
//        }
        return .empty
    }
}

