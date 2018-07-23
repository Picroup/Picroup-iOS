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
    
    var imageMinioId: Binder<String?> {
        return Binder(base) { imageView, minioId in
            imageView.setImage(with: minioId)
        }
    }
}

extension Reactive where Base: UIImageView {
    
    var userAvatar: Binder<UserObject?> {
        return Binder(base) { imageView, user in
            imageView.setUserAvatar(with: user)
        }
    }
}

extension UIImageView {
    
    func setImage(with minioId: String?) {
        let url = URLHelper.url(from: minioId)
        kf.setImage(with: url, options: [.transition(.fade(0.2))])
    }
}

extension UIImageView {
    
    func setUserAvatar(with user: UserObject?) {
        switch (user?.avatarId, user?.displayName) {
        case (let avatarId?, _):
            setImage(with: avatarId)
        case (_, let displayName?) where !displayName.isEmpty:
            let (first, color) = (displayName.first!, avatarColor(for: displayName))
            let imageKey = "local://\(first).\(color.hashValue)"
            let cached = ImageCache.default.imageCachedType(forKey: imageKey) != .none
            if cached {
                kf.setImage(with: URL(string: imageKey), options: [.transition(.fade(0.2))])
            } else {
                let image = ImageGenerator.image(char: first, color: color)
                ImageCache.default.store(image, forKey: imageKey)
                self.image = image
            }
        default:
            setImage(with: nil)
        }
    }
}

fileprivate func avatarColor(for displayName: String) -> UIColor {
    let colors: [UIColor] =  [
        .lightGray,
        .gray,
        .orange,
        .brown,
        ]
    return colors[displayName.count % colors.count]
}
