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

extension String {
    func toURL() -> URL? {
        return URL(string: self)
    }
}

extension UIImageView {
    
    func setImage(with url: URL?) {
        kf.setImage(with: url, options: [.transition(.fade(0.2))])
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
    
    func setUserAvatar(with item: UserPresentable?) {
        switch (item?.avatarURL, item?.displayNameDisplay) {
        case (let url?, _):
            setImage(with: url)
        case (_, let displayName?) where !displayName.isEmpty:
            let (first, color) = (displayName.first!, avatarColor(for: displayName))
            let imageKey = "local://\(first).\(color.hashValue)"
            let cached = ImageCache.default.imageCachedType(forKey: imageKey) != .none
            if cached {
                setImage(with: imageKey.toURL())
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
