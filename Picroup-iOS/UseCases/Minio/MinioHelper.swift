//
//  MinioHelper.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire
import MobileCoreServices

struct MinioHelper {
    
    enum Error: Swift.Error {
        case signedURLNotFound
    }
    
    static func save(with fileURL: URL) -> Observable<RxProgress> {
        return json(.get, "\(Config.baseURL)/signed?name=\(fileURL.lastPathComponent)")
            .map { json in (json as? [String: String])?["signedURL"] }
            .flatMap { signedURL -> Observable<RxProgress> in
                guard let signedURL = signedURL else { throw Error.signedURLNotFound }
                let headers = fileURL.mimeType.map { ["Content-Type":$0] }
                return upload(fileURL, to: signedURL, method: .put, headers: headers)
                    .rx.progress()
        }
    }
}

private extension URL {
    
    var mimeType: String? {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue(),
            let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
            else { return nil }
        return mimeType as String
    }
}
