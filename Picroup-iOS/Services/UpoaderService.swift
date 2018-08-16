//
//  UpoaderService.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/17.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Alamofire
import RxSwift
import RxAlamofire
import Kingfisher

struct UpoaderService {
    
    enum Error: Swift.Error {
        case generateImageDataFail
        case generateVideoDataFail
        case imageTooLarge
    }
    
    static func uploadImage(_ image: UIImage) -> (progress: Observable<RxProgress>, filename: String) {
        let filename = "\(UUID().uuidString).jpg"
        let progress: Observable<RxProgress> = {
            guard image.size.area < 4096 * 4096 else { return .error(Error.imageTooLarge) }
            guard let imageData = UIImageJPEGRepresentation(image, compressionQuality(for: image)) else { return .error(Error.generateImageDataFail) }
            let (save, url) = MinioHelper.save(with: imageData, filename: filename)
            return save
                .do(onCompleted: { ImageCache.default.store(image, forKey: url) })
        }()
        return (progress, filename)
    }
    
    static func uploadVideo(with fileURL: URL) -> (progress: Observable<RxProgress>, filename: String) {
        let filename = "\(UUID().uuidString).\(fileURL.pathExtension)"
        let progress: Observable<RxProgress> = {
            guard let vidoeData = try? Data(contentsOf: fileURL) else { return .error(Error.generateVideoDataFail) }
            let (save, url) = MinioHelper.save(with: vidoeData, filename: filename)
            return save
                .do(onCompleted: { Cacher.storage?.async.setObject(vidoeData, forKey: url, completion: { _ in }) })
        }()
        return (progress, filename)
    }
    
    private static func compressionQuality(for image: UIImage) -> CGFloat {
        let area = image.size.area
        let criticalArea: CGFloat = 800 * 800
        return area < criticalArea ? 1 : (criticalArea / area)
    }
}

private extension CGSize {
    var area: CGFloat {
        return width * height
    }
}



