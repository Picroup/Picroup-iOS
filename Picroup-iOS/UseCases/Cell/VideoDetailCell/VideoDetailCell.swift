//
//  VideoDetailCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa

class VideoDetailCell: RxCollectionViewCell {
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var lifeBar: UIView!
    @IBOutlet weak var starButton: FABButton! {
        didSet { starButton.image = Icon.favorite }
    }
    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    func configure(
        with item: MediumObject,
        onStarButtonTap: (() -> Void)?,
        onCommentsTap: (() -> Void)?,
        onImageViewTap: (() -> Void)?,
        onUserTap: (() -> Void)?,
        onMoreTap: (() -> Void)?
        ) {
        if item.isInvalidated { return }
        let viewModel = ImageDetailViewModel(medium: item)
        
        playerView.motionIdentifier = viewModel.imageViewMotionIdentifier
        lifeBar.motionIdentifier = viewModel.lifeBarMotionIdentifier
        starButton.motionIdentifier = viewModel.starButtonMotionIdentifier
        lifeViewWidthConstraint.constant = viewModel.progress * lifeBar.bounds.width
        userAvatarImageView.setUserAvatar(with: item.user)
        displayNameLabel.text = viewModel.displayName
        remainTimeLabel.text = viewModel.remainTimeLabelText
        commentButton.setTitle(viewModel.commentsCountText, for: .normal)
        configureStarButton(with: viewModel)
        if viewModel.animatedChangeProgress {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.layoutIfNeeded()
            })
        }
        
        if let onCommentsTap = onCommentsTap {
            commentButton.rx.tap
                .subscribe(onNext: onCommentsTap)
                .disposed(by: disposeBag)
        }
        
        if let onStarButtonTap = onStarButtonTap {
            starButton.rx.tap
                .subscribe(onNext: onStarButtonTap)
                .disposed(by: disposeBag)
        }
        
        if let onImageViewTap = onImageViewTap {
            playerView.rx.tapGesture().when(.recognized)
                .mapToVoid()
                .subscribe(onNext: onImageViewTap)
                .disposed(by: disposeBag)
        }
        
        if let onUserTap = onUserTap {
            userView.rx.tapGesture().when(.recognized)
                .mapToVoid()
                .subscribe(onNext: onUserTap)
                .disposed(by: disposeBag)
        }
        
        if let onMoreTap = onMoreTap {
            moreButton.rx.tap
                .subscribe(onNext: onMoreTap)
                .disposed(by: disposeBag)
        }
    }
    
    private func configureStarButton(with viewModel: ImageDetailViewModel) {
        starButton.isEnabled = viewModel.stared == false
        StarButtonPresenter.isSelected(base: starButton).onNext(viewModel.stared)
    }
}
