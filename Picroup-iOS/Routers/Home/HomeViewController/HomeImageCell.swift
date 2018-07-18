//
//  HomeImageCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import Material
import RxSwift
import RxCocoa


class HomeImageCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var lifeBar: UIView!
    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var suggestUpdateLabel: UILabel!

    func configure(
        with item: MediumObject,
        onCommentsTap: (() -> Void)?,
        onImageViewTap: (() -> Void)?,
        onUserTap: (() -> Void)?
        ) {
        guard !item.isInvalidated else { return  }
        
        let remainTime = item.endedAt.value?.sinceNow ?? 0
        
        if item.kind == MediumKind.image.rawValue {
            imageView.setImage(with: item.minioId)
            suggestUpdateLabel.isHidden = true
        } else {
            imageView.image = nil
            suggestUpdateLabel.isHidden = false
        }
        lifeViewWidthConstraint.constant = CGFloat(remainTime / 12.0.weeks) * lifeBar.bounds.width
        imageView.motionIdentifier = item._id
        lifeBar.motionIdentifier = "lifeBar_\(item._id)"
        userAvatarImageView.setUserAvatar(with: item.user)
        displayNameLabel.text = item.user?.displayName
        commentButton.setTitle("  \(item.commentsCount.value ?? 0)", for: UIControlState.normal)
        
        if let onCommentsTap = onCommentsTap {
            commentButton.rx.tap
                .subscribe(onNext: onCommentsTap)
                .disposed(by: disposeBag)
        }
        
        if let onImageViewTap = onImageViewTap {
            imageButton.rx.tap
                .subscribe(onNext: onImageViewTap)
                .disposed(by: disposeBag)
        }
        
        if let onUserTap = onUserTap {
            userView.rx.tapGesture().when(.recognized).mapToVoid()
                .subscribe(onNext: onUserTap)
                .disposed(by: disposeBag)
        }
        
    }
}

class HomeVidoeCell: RxCollectionViewCell {
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var lifeBar: UIView!
    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    func configure(
        with item: MediumObject,
        onCommentsTap: (() -> Void)?,
        onImageViewTap: (() -> Void)?,
        onUserTap: (() -> Void)?
        ) {
        guard !item.isInvalidated else { return  }
        
        let remainTime = item.endedAt.value?.sinceNow ?? 0
        
        playerView.play(with: item.detail?.videoMinioId)
//        playerView.play(url: URL(string: "http://minio.picroup.com:9000/picroup.dev/1F941694-103E-4EAA-B916-458889E1CF8A.mp4"))
        lifeViewWidthConstraint.constant = CGFloat(remainTime / 12.0.weeks) * lifeBar.bounds.width
//        imageView.motionIdentifier = item._id
        lifeBar.motionIdentifier = "lifeBar_\(item._id)"
        userAvatarImageView.setUserAvatar(with: item.user)
        displayNameLabel.text = item.user?.displayName
        commentButton.setTitle("  \(item.commentsCount.value ?? 0)", for: UIControlState.normal)
        
        if let onCommentsTap = onCommentsTap {
            commentButton.rx.tap
                .subscribe(onNext: onCommentsTap)
                .disposed(by: disposeBag)
        }
        
        if let onImageViewTap = onImageViewTap {
            imageButton.rx.tap
                .subscribe(onNext: onImageViewTap)
                .disposed(by: disposeBag)
        }
        
        if let onUserTap = onUserTap {
            userView.rx.tapGesture().when(.recognized).mapToVoid()
                .subscribe(onNext: onUserTap)
                .disposed(by: disposeBag)
        }
        
    }
}
