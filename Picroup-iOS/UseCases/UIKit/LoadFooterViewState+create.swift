//
//  LoadFooterViewState+create.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

extension LoadFooterViewState {
    
    static func create(cursor: Double?, trigger: Bool, error: String?) -> LoadFooterViewState {
        if cursor == nil && trigger {
            return .empty
        }
        if error != nil {
            return .message("💁🏻‍♀️ 加载失败，请重试")
        }
        if cursor != nil && trigger {
            return .loading
        }
        if cursor == nil && !trigger {
            return .message("🙆🏻‍♀️")
        }
        return .empty
    }
}

extension LoadFooterViewState {
    
    static func create(searchUser: SearchUserStateObject) -> LoadFooterViewState {
        if searchUser.triggerSearchUserQuery {
            return .loading
        }
        if !searchUser.searchText.isEmpty && !searchUser.triggerSearchUserQuery  && searchUser.user == nil {
            return .message("💁🏻‍♀️ 无此人")
        }
        return .empty
    }
}
