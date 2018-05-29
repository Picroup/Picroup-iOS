//
//  ReputationCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

class ReputationCell: RxTableViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var mediumImageView: UIImageView!
    
    func configure(with item: ReputationObject) {
        guard !item.isInvalidated else { return }
        
        valueLabel.text = "+\(item.value.value ?? 0)"
        userAvatarImageView.setImage(with: item.user?.avatarId)
        mediumImageView.setImage(with: item.medium?.minioId)
        switch item.kind {
        case "saveMedium"?:
            contentLabel.text = "分享了图片"
        case "starMedium"?:
            contentLabel.text = "给你的图片续命"
        case "followUser"?:
            contentLabel.text = "关注了你"
        default:
            contentLabel.text = "  "
        }
    }
}


