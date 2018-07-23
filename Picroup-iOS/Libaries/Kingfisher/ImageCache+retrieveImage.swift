//
//  ImageCache+retrieveImage.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Kingfisher

extension ImageCache {
    
    func retrieveImage(forKey key: String, options: KingfisherOptionsInfo? = nil) -> Image? {
        switch imageCachedType(forKey: key) {
        case .none:
            return nil
        case .memory:
            return retrieveImageInMemoryCache(forKey: key, options: options)
        case .disk:
            return retrieveImageInDiskCache(forKey: key, options: options)
        }
    }
}
