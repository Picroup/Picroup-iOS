//
//  Cacher.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import Cache

struct Cacher {

    static let storage: Cache.Storage? = {
        let diskConfig = DiskConfig(name: "DiskCache", maxSize: Config.maxDiskVideoCacheSize) 
        let memoryConfig = MemoryConfig(countLimit: Config.maxMemoryVideoCacheCount)
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
    }()
}

