//
//  ImageUpoader.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/3/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Alamofire
import RxSwift
import RxAlamofire

struct ImageUpoader {
    
    enum Error: Swift.Error {
        case signedURLNotFound
        case generateImageDataFail
        case imageTooLarge
    }
    
    static func uploadImage(_ image: UIImage) -> (progress: Observable<RxProgress>, filename: String) {
        let filename = "\(UUID().uuidString).jpg"
        let progress = json(.get, "\(Config.baseURL)/signed?name=\(filename)")
            .map { json in (json as? [String: String])?["signedURL"] }
            .flatMap { url -> Observable<RxProgress> in
                guard let url = url else { throw Error.signedURLNotFound }
                guard image.size.area < 3072 * 3072 else { throw Error.imageTooLarge }
                guard let imageData = UIImageJPEGRepresentation(image, compressionQuality(for: image)) else { throw Error.generateImageDataFail }
                return upload(imageData, to: url, method: .put, headers: ["Content-Type":"image/jpeg"])
                    .rx.progress()
        }
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



