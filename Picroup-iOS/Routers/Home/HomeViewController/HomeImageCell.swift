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
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    func configure(
        with item: MediumObject,
        onCommentsTap: (() -> Void)?,
        onImageViewTap: (() -> Void)?,
        onUserTap: (() -> Void)?
        ) {
        guard !item.isInvalidated else { return  }
        
        let remainTime = item.endedAt.value?.sinceNow ?? 0
        
        imageView.setImage(with: item.minioId)
        lifeViewWidthConstraint.constant = CGFloat(remainTime / 12.0.weeks) * lifeBar.bounds.width
        imageView.motionIdentifier = item._id
        lifeBar.motionIdentifier = "lifeBar_\(item._id)"
        userAvatarImageView.setImage(with: item.user?.avatarId)
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
