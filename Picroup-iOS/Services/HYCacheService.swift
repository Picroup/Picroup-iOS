//
//  DefaultCacheService.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import struct Foundation.URL
import struct Foundation.Data
import class Foundation.DispatchQueue

import class Cache.DiskStorage
import struct Cache.DiskConfig
import class Cache.TransformerFactory

extension HYDefaultCacheService {
    
    static let shared: HYDefaultCacheService? = {
        let diskConfig = DiskConfig(name: "DiskCache", maxSize: Config.maxDiskVideoCacheSize)
        do {
            let storage = try DiskStorage(config: diskConfig, transformer: TransformerFactory.forData())
            return HYDefaultCacheService(storage: storage)
        } catch {
            print("create HYDefaultCacheService error \(error.localizedDescription)")
            return nil
        }
    }()
}

final class HYDefaultCacheService: CacheService {
    
    fileprivate let storage: DiskStorage<Data>
    
    init(storage: DiskStorage<Data>) {
        self.storage = storage
    }
    
    func set(_ data: Data, for remoteURL: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.storage.setObject(data, forKey: remoteURL.absoluteString)
            } catch {
                print("cache error \(error.localizedDescription) for \(remoteURL)")
            }
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
    
    func removeExpiredObjects() {
        do {
            try storage.removeExpiredObjects()
        } catch {
            print("storage removeExpiredObjects error \(error.localizedDescription)")
        }
    }
}
