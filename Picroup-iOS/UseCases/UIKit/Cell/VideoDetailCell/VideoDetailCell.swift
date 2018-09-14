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
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var starButton: FABButton! {
        didSet { starButton.image = Icon.favorite }
    }
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: SpinnerButton!
    @IBOutlet weak var moreButton: UIButton!
    
    func configure(
        with item: MediumObject,
        isSharing: Driver<Bool>,
        onStarButtonTap: ((String) -> Void)?,
        onCommentsTap: ((String) -> Void)?,
        onImageViewTap: ((String) -> Void)?,
        onUserTap: ((String) -> Void)?,
        onShareTap: ((String) -> Void)?,
        onMoreTap: ((String) -> Void)?
        ) {
        
        if item.isInvalidated { return }

        item.rx.observe()
            .asDriverOnErrorRecoverEmpty()
            .drive(rxItem)
            .disposed(by: disposeBag)
        
        isSharing.distinctUntilChanged()
            .drive(shareButton.rx.spinning)
            .disposed(by: disposeBag)
        
        let mediumId = item._id

        if let onCommentsTap = onCommentsTap {
            commentButton.rx.tap
                .subscribe(onNext: { onCommentsTap(mediumId) })
                .disposed(by: disposeBag)
        }
        
        if let onStarButtonTap = onStarButtonTap {
            starButton.rx.tap
                .subscribe(onNext: { onStarButtonTap(mediumId) })
                .disposed(by: disposeBag)
        }
        
        if let onImageViewTap = onImageViewTap {
            playerView.rx.tapGesture().when(.recognized)
                .mapToVoid()
                .subscribe(onNext: { onImageViewTap(mediumId) })
                .disposed(by: disposeBag)
        }
        
        if let onUserTap = onUserTap, let userId = item.userId {
            userView.rx.tapGesture().when(.recognized)
                .mapToVoid()
                .subscribe(onNext: { onUserTap(userId) })
                .disposed(by: disposeBag)
        }
        
        if let onShareTap = onShareTap {
            shareButton.rx.tap
                .mapToVoid()
                .subscribe(onNext: { onShareTap(mediumId) })
                .disposed(by: disposeBag)
        }
        
        if let onMoreTap = onMoreTap {
            moreButton.rx.tap
                .subscribe(onNext: { onMoreTap(mediumId) })
                .disposed(by: disposeBag)
        }
    }
    
    private var rxItem: Binder<MediumObject> {
        return Binder(self) { cell, item in
            if item.isInvalidated { return }
            let viewModel = ImageDetailViewModel(medium: item)
            cell.playerView.backgroundColor = viewModel.placeholderColor
            cell.progressView.progress = viewModel.progress
            cell.userAvatarImageView.setUserAvatar(with: item.user)
            cell.displayNameLabel.text = viewModel.displayName
            cell.remainTimeLabel.text = viewModel.remainTimeLabelText
            cell.commentButton.setTitle(viewModel.commentsCountText, for: .normal)
            cell.motionIdentifier = viewModel.cellMotionIdentifier
            cell.playerView.motionIdentifier = viewModel.imageViewMotionIdentifier
            cell.progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
            cell.remainTimeLabel.motionIdentifier = viewModel.remainTimeLabelMotionIdentifier
            cell.starButton.motionIdentifier = viewModel.starButtonMotionIdentifier
            DispatchQueue.main.async {
                StarButtonPresenter.isMediumStared(base: cell.starButton).onNext(viewModel.stared)
            }
        }
    }
}
