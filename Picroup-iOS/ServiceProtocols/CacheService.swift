//
//  CacheService.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import struct Foundation.URL
import struct Foundation.Data

protocol CacheService {
    
    func set(_ data: Data, for remoteURL: URL)
    func fileURL(for remoteURL: URL) -> URL?
    func removeExpiredObjects()
}
