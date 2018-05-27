//
//  LocalStorage.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/4.
//  Copyright © 2018年 luojie. All rights reserved.
//


import Foundation

public class LocalStorage {
    
    let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension LocalStorage {
    
    public static let standard = LocalStorage(userDefaults: .standard)
}

