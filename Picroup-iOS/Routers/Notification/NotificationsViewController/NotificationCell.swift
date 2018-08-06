//
//  NotificationCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

final class NotificationCell: RxTableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var mediumImageView: UIImageView!
    
    func configure(with item: NotificationObject) {
        guard !item.isInvalidated else { return }
        
        userAvatarImageView.setUserAvatar(with: item.user)
        mediumImageView.setImage(with: item.medium?.minioId)
        mediumImageView.backgroundColor = item.medium?.placeholderColor
        mediumImageView.motionIdentifier = item.medium?._id
        switch item.kind {
        case NotificationKind.commentMedium.rawValue?:
            contentLabel.text = "评论了你的图片"
        case NotificationKind.starMedium.rawValue?:
            contentLabel.text = "给你的图片续命"
        case NotificationKind.followUser.rawValue?:
            contentLabel.text = "关注了你"
        default:
            contentLabel.text = "类型未知，请升级应用后查看"
        }
    }
}
