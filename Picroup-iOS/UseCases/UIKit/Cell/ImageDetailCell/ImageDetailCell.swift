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

        Observable.from(object: item)
            //            .bind(to: rxItem)
            .asDriverOnErrorRecoverEmpty()
            .drive(rxItem)
            .disposed(by: disposeBag)
        
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
    
    private var rxItem: Binder<MediumObject> {
        return Binder(self) { cell, item in
            if item.isInvalidated { return }
            let viewModel = ImageDetailViewModel(medium: item)
            
            if viewModel.kind == MediumKind.image.rawValue {
                cell.imageView.setImage(with: item.minioId)
                cell.suggestUpdateLabel.isHidden = true
            } else {
                cell.imageView.image = nil
                cell.suggestUpdateLabel.isHidden = false
            }
            cell.imageView.backgroundColor = viewModel.placeholderColor
            cell.imageView.motionIdentifier = viewModel.imageViewMotionIdentifier
            cell.progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
            cell.progressView.progress = viewModel.progress
            cell.starButton.motionIdentifier = viewModel.starButtonMotionIdentifier
            cell.userAvatarImageView.setUserAvatar(with: item.user)
            cell.displayNameLabel.text = viewModel.displayName
            cell.remainTimeLabel.text = viewModel.remainTimeLabelText
            cell.commentButton.setTitle(viewModel.commentsCountText, for: .normal)
            DispatchQueue.main.async { cell.configureStarButton(with: viewModel) }
            
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
