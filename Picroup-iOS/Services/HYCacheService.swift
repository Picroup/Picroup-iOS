//
//  DefaultCacheService.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import struct Foundation.URL
import class Foundation.FileManager
import struct Foundation.FileAttributeKey
import struct Foundation.Date
import struct Foundation.Data
import class Foundation.DispatchQueue

import class Cache.Storage
import class Cache.DiskStorage
import struct Cache.DiskConfig
import class Cache.TransformerFactory

extension HYDefaultCacheService {
    
    static let shared: HYDefaultCacheService? = {
        let diskConfig = DiskConfig(name: "DiskCache", maxSize: Config.maxDiskVideoCacheSize)
        let storage = try? DiskStorage(config: diskConfig, transformer: TransformerFactory.forData())
        return storage.map(HYDefaultCacheService.init)
    }()
}

final class HYDefaultCacheService: CacheService {
    
    fileprivate let storage: DiskStorage<Data>
    
    init(storage: DiskStorage<Data>) {
        self.storage = storage
    }
    
    func set(_ data: Data, for remoteURL: URL) {
        do {
            try storage.setObject(data, forKey: remoteURL.absoluteString)
        } catch {
            print("cache error \(error.localizedDescription) for \(remoteURL)")
        }
    }
    
    func fileURL(for remoteURL: URL) -> URL? {
        do {
            let entry = try storage.entry(forKey: remoteURL.absoluteString)
            return entry.filePath.map(URL.init(fileURLWithPath:))
        } catch {
            return nil
        }
    }
}
