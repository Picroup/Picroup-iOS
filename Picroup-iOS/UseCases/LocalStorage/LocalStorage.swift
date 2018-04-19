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
        static let createImageSelectedCategory = "createImageSelectedCategory"
        static let rankImageSelectedCategory = "rankImageSelectedCategory"
    }
    
    var createImageSelectedCategory: MediumCategory {
        get {
            let rawValue = _userDefaults.value(forKey: Keys.createImageSelectedCategory) as? String
            return rawValue.flatMap(MediumCategory.init(rawValue: )) ?? .popular
        }
        set {
            let rawValue = newValue.rawValue
            _userDefaults.set(rawValue, forKey: Keys.createImageSelectedCategory)
        }
    }
    
    var rankImageSelectedCategory: MediumCategory? {
        get {
            let rawValue = _userDefaults.value(forKey: Keys.rankImageSelectedCategory) as? String
            return rawValue.flatMap(MediumCategory.init(rawValue: ))
        }
        set {
            let rawValue = newValue?.rawValue
            _userDefaults.set(rawValue, forKey: Keys.rankImageSelectedCategory)
        }
    }
}


extension LocalStorage {
    
    static let standard = LocalStorage(userDefaults: .standard)
}
