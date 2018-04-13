//
//  UIImageView+RxMinioId.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/12.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

extension Reactive where Base: UIImageView {
    
    var minioId: Binder<String?> {
        return Binder(base) { imageView, minioId in
            let url = minioId
                .map { "\(Config.baseURL)/s3?name=\($0)" }
                .flatMap(URL.init(string: ))
            imageView.kf.setImage(with: url)
        }
    }
}

extension UIImageView {
    
    func setImage(with minioId: String?) {
        let url = minioId
            .map { "\(Config.baseURL)/s3?name=\($0)" }
            .flatMap(URL.init(string: ))
        kf.setImage(with: url)
    }
}
