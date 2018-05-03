//
//  LocalStorage.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

class LocalStorage {
    
    fileprivate let _userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        _userDefaults = userDefaults
    }
}

extension LocalStorage {
    
    private struct Keys {
    }
}


extension LocalStorage {
    
    static let standard = LocalStorage(userDefaults: .standard)
}
