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
        with item: MediumPresentable,
        isSharing: Driver<Bool>,
        onStarButtonTap: ((String) -> Void)?,
        onCommentsTap: ((String) -> Void)?,
        onImageViewTap: ((String) -> Void)?,
        onUserTap: ((String) -> Void)?,
        onShareTap: ((String) -> Void)?,
        onMoreTap: ((String) -> Void)?
        ) {
        
        if item.isInvalidated { return }
        
        item.asDriver()
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
        
        if let onUserTap = onUserTap, let userId = item.userDisplay?._id {
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
    
    private var rxItem: Binder<MediumPresentable> {
        return Binder(self) { cell, item in
            if item.isInvalidated { return }
            cell.playerView.backgroundColor = item.placeholderColor
            cell.progressView.progress = item.lifeProgress
            cell.userAvatarImageView.setUserAvatar(with: item.userDisplay)
            cell.displayNameLabel.text = item.userDisplay?.displayNameDisplay
            cell.remainTimeLabel.text = item.remainTimeDisplay
            cell.commentButton.setTitle(item.commentsCountDisplay, for: .normal)
            cell.motionIdentifier = item.cellMotionIdentifier
            cell.playerView.motionIdentifier = item.imageViewMotionIdentifier
            cell.progressView.motionIdentifier = item.lifeBarMotionIdentifier
            cell.remainTimeLabel.motionIdentifier = item.remainTimeLabelMotionIdentifier
            cell.starButton.motionIdentifier = item.starButtonMotionIdentifier
            DispatchQueue.main.async {
                StarButtonPresenter.isMediumStared(base: cell.starButton).onNext(item.isStared)
            }
        }
    }
}
