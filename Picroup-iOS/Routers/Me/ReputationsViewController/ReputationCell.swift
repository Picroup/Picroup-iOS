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
        userAvatarImageView.setUserAvatar(with: item.user)
        mediumImageView.setImage(with: item.medium?.url?.toURL())
        mediumImageView.backgroundColor = item.medium?.placeholderColor
        mediumImageView.motionIdentifier = item.medium?._id
        switch item.kind {
        case ReputationKind.saveMedium.rawValue?:
            contentLabel.text = "分享了\(item.medium?.kindDescripting ?? "")"
        case ReputationKind.starMedium.rawValue?:
            contentLabel.text = "给你的\(item.medium?.kindDescripting ?? "")续命"
        case ReputationKind.followUser.rawValue?:
            contentLabel.text = "关注了你"
        default:
            contentLabel.text = "类型未知，请升级应用后查看"
        }
    }
}


extension MediumObject {
    var kindDescripting: String {
        switch self.kind {
        case MediumKind.image.rawValue?:
            return "图片"
        case MediumKind.video.rawValue?:
            return "视频"
        default:
            return "媒体"
        }
    }
}
