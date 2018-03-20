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
    }
    
    static func uploadImage(_ image: UIImage, compressionQuality: CGFloat = 0.5) -> (progress: Observable<RxProgress>, filename: String) {
        let filename = "\(UUID().uuidString).jpg"
        let progress = json(.get, "\(Config.baseURL)/signed?name=\(filename)")
            .map { json in (json as? [String: String])?["signedURL"] }
            .flatMap { url -> Observable<RxProgress> in
                guard let url = url else { throw Error.signedURLNotFound }
                guard let imageData = UIImageJPEGRepresentation(image, compressionQuality) else { throw Error.generateImageDataFail }
                return upload(imageData, to: url, method: .put, headers: ["Content-Type":"image/jpeg"])
                    .rx.progress()
        }
        return (progress, filename)
    }
    
}


