//
//  MediaItemObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

final class MediaItemObject: PrimaryObject {
    @objc dynamic var kind: String?
    @objc dynamic var imageKey: String?
    @objc dynamic var thumbnailImageKey: String?
    @objc dynamic var videoFilePath: String?
    
    var videoFileURL: URL? {
        get { return videoFilePath.flatMap(URL.init(string: )) }
        set { videoFilePath = newValue?.absoluteString }
    }
    
    static func create(mediaItem: MediumItem) -> (Realm) -> MediaItemObject {
        return { realm in
            
            let value: Any = {
                switch mediaItem {
                case .image(let imageKey):
                    return [
                        "_id": mediaItem.id,
                        "kind": MediumKind.image.rawValue,
                        "imageKey": imageKey,
                    ]
                case .video(let thumbnailImageKey, let videoFileURL):
                    return [
                        "_id": mediaItem.id,
                        "kind": MediumKind.video.rawValue,
                        "thumbnailImageKey": thumbnailImageKey,
                        "videoFilePath": videoFileURL.absoluteString,
                    ]
                }
            }()
            
            return realm.create(MediaItemObject.self, value: value)
        }
    }
    
    var mediaItem: MediumItem {
        switch (kind, imageKey, thumbnailImageKey, videoFileURL) {
        case (MediumKind.image.rawValue?, let imageKey?, _, _):
            return .image(imageKey)
        case (MediumKind.video.rawValue?, _, let thumbnailImageKey?, let videoFileURL?):
            return .video(thumbnailImageKey: thumbnailImageKey, videoFileURL: videoFileURL)
        default:
            fatalError("CreateMediaQueryObject can't convert to MediaItem: \(self)")
        }
    }
}

extension MediumItem {
    var id: String {
        switch self {
        case .image(let imageKey):
            return imageKey
        case .video(let thumbnailImageKey, _):
            return thumbnailImageKey
        }
    }
}
