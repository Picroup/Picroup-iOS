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
import Apollo

struct MinioHelper {
    
    enum Error: Swift.Error {
        case signedURLNotFound
    }
    
    static func save(with data: Data, filename: String) -> (Observable<RxProgress>, String) {
        
        let save = ApolloClient.shared.rx.fetch(query: PresignedPutUrlQuery(minioId: filename), cachePolicy: .fetchIgnoringCacheData)
            .map { result in result?.data?.presignedPutUrl }.asObservable()
            .flatMap { signedURL -> Observable<RxProgress> in
                guard let signedURL = signedURL else { throw Error.signedURLNotFound }
                let pathExtension = filename.split(separator: ".").last.map(String.init)
                let headers = pathExtension.flatMap { $0.mimeType }.map { ["Content-Type":$0] }
                return upload(data, to: signedURL, method: .put, headers: headers)
                    .rx.progress()
        }
        let url = "\(Config.baseURL)/files/\(filename)"
        return (save, url)
    }
}

extension String {
    
    var mimeType: String? {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self as NSString, nil)?.takeRetainedValue(),
            let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
            else { return nil }
        return mimeType as String
    }
}
