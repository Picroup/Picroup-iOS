//
//  ImageCache+Rx.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift
import RxCocoa
import Kingfisher

//extension ImageCache: ReactiveCompatible {}
//
//extension Reactive where Base: ImageCache {
//
//    public func store(_ image: Image,
//               original: Data? = nil,
//               forKey key: String,
//               processorIdentifier identifier: String = "",
//               cacheSerializer serializer: CacheSerializer = DefaultCacheSerializer.default,
//               toDisk: Bool = true) -> Completable {
//        return Completable.create { observer in
//            self.base.store(image,
//                            original: original,
//                            forKey: key,
//                            processorIdentifier: identifier,
//                            cacheSerializer: serializer,
//                            toDisk: toDisk,
//                            completionHandler: { observer(.completed) }
//            )
//            return Disposables.create()
//        }
//    }
//}
