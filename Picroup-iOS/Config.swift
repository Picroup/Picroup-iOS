//
//  Config.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/3/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

struct Config {
    static let baseURL = developBaseURL
    static let productionBaseURL = "https://api.picroup.com:4000"
    static let developBaseURL = "https://home.picroup.com:3500"
    static let maxDiskImageCacheSize: UInt = 100 * 1024 * 1024 // 100 MB
    static let maxDiskVideoCacheSize: UInt = 150 * 1024 * 1024 // 100 MB
    static let maxMemoryVideoCacheCount: UInt = 24
    static let realmSchemaVersion: UInt64 = 25
}
