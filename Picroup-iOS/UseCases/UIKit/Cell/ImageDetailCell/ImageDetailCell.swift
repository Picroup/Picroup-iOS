//
//  ImageDetailCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/18.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa

struct ImageDetailViewModel {
    let kind: String?
    let imageViewMinioId: String?
    let imageViewMotionIdentifier: String?
    let progress: Float
    let lifeBarMotionIdentifier: String?
    let starButtonMotionIdentifier: String?
    let remainTimeLabelText: String?
    let commentsCountText: String
    let stared: Bool?
    let animatedChangeProgress: Bool
    let placeholderColor: UIColor

    let displayName: String?
    let avatarId: String?
}

extension ImageDetailViewModel {
    
    init(medium: MediumObject) {
        guard !medium.isInvalidated else {
            self.kind = nil
            self.imageViewMinioId = nil
            self.imageViewMotionIdentifier = nil
            self.progress = 0
            self.lifeBarMotionIdentifier = nil
            self.starButtonMotionIdentifier = nil
            self.remainTimeLabelText = "\(0) 周"
            self.commentsCountText = "\(0)"
            self.stared = nil
            self.animatedChangeProgress = false
            self.displayName = nil
            self.avatarId = nil
            self.placeholderColor = .background
            return
        }
        let remainTime = medium.endedAt.value?.sinceNow ?? 0
        
        self.kind = medium.kind
        self.imageViewMinioId = medium.minioId
        self.imageViewMotionIdentifier = medium._id
        self.progress = Float(remainTime / 12.0.weeks)
        self.lifeBarMotionIdentifier = "lifeBar_\(medium._id)"
        self.starButtonMotionIdentifier = "starButton_\(medium._id)"
        self.remainTimeLabelText = Moment.string(from: medium.endedAt.value)
        self.commentsCountText = "  \(medium.commentsCount.value ?? 0)"
        self.stared = medium.stared.value
        self.animatedChangeProgress = false
        self.placeholderColor = medium.placeholderColor

        self.displayName = medium.user?.displayName
        self.avatarId = medium.user?.avatarId
    }
}

class ImageDetailCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
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
    @IBOutlet weak var suggestUpdateLabel: UILabel!

    func configure(
        with item: MediumObject,
        isSharing: Driver<Bool>,
        onStarButtonTap: (() -> Void)?,
        onCommentsTap: (() -> Void)?,
        onImageViewTap: (() -> Void)?,
        onUserTap: (() -> Void)?,
        onShareTap: (() -> Void)?,
        onMoreTap: (() -> Void)?
        ) {
        if item.isInvalidated { return }
        let viewModel = ImageDetailViewModel(medium: item)
        
        if viewModel.kind == MediumKind.image.rawValue {
            imageView.setImage(with: item.minioId)
            suggestUpdateLabel.isHidden = true
        } else {
            imageView.image = nil
            suggestUpdateLabel.isHidden = false
        }
        imageView.backgroundColor = viewModel.placeholderColor
        imageView.motionIdentifier = viewModel.imageViewMotionIdentifier
        progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
        progressView.progress = viewModel.progress
        starButton.motionIdentifier = viewModel.starButtonMotionIdentifier
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
        
        isSharing.distinctUntilChanged()
            .drive(shareButton.rx.spinning)
            .disposed(by: disposeBag)

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
            imageView.rx.tapGesture().when(.recognized)
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
        
        if let onShareTap = onShareTap {
            shareButton.rx.tap
                .mapToVoid()
                .subscribe(onNext: onShareTap)
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

struct StarButtonPresenter {
    
    static func isSelected(base: FABButton) -> Binder<Bool?> {
        return Binder(base) { button, isSelected in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                guard let isSelected = isSelected else {
                    button.alpha = 0
                    return
                }
                button.alpha =  1
                if !isSelected {
                    button.backgroundColor = .primaryText
                    button.tintColor = .secondary
                } else {
                    button.backgroundColor = .secondary
                    button.tintColor = .primaryText
                }
            })
        }
    }
}

extension Reactive where Base: SpinnerButton {
    
    var spinning: Binder<Bool> {
        return Binder(base) { spinnerButton, spinning in
            spinning ? spinnerButton.startSpinning() : spinnerButton.stopSpinning()
        }
    }
}
