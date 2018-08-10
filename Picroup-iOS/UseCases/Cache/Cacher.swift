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

    static let diskConfig = DiskConfig(name: "DiskCache", maxSize: Config.maxDiskVideoCacheSize)
    
    static let storage: Cache.Storage? = {
        let memoryConfig = MemoryConfig(countLimit: Config.maxMemoryVideoCacheCount)
        return try? Cache.Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
    }()
    
    static func fileURL(for key: String) -> URL? {
        let fileManager = FileManager.default
        do {
            let url = try fileManager.url(
                for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true
            )
            let path = url.appendingPathComponent(diskConfig.name, isDirectory: true).path
            let filePath = "\(path)/\(MD5(key))"
            return URL(fileURLWithPath: filePath)
        } catch  {
            return nil
        }
    }
}

