//
//  MediumItemHelper.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct MediumItemHelper {
    
    static func mediumItem(from medium: MediumObject?) -> MediumItem? {
        switch medium?.kind {
        case MediumKind.image.rawValue?:
            guard let cacheKey = medium?.url else {
                return nil
            }
            return .image(cacheKey)
        case MediumKind.video.rawValue?:
            guard let url = medium?.detail?.videoURL?.toURL() else {
                return nil
            }
            return .video(thumbnailImageKey: "ignore", videoFileURL: url)
        default:
            return nil
        }
    }
}
