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
            imageView.rx.tapGesture().when(.recognized)
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
            if item.mediumKind == MediumKind.image {
                cell.imageView.setImage(with: item.imageURL)
                cell.suggestUpdateLabel.isHidden = true
            } else {
                cell.imageView.image = nil
                cell.suggestUpdateLabel.isHidden = false
            }
            cell.imageView.backgroundColor = item.placeholderColor
            cell.progressView.progress = item.lifeProgress
            
            cell.userAvatarImageView.setUserAvatar(with: item.userDisplay)
            cell.displayNameLabel.text = item.userDisplay?.displayNameDisplay
            
            cell.remainTimeLabel.text = item.remainTimeDisplay
            cell.commentButton.setTitle(item.commentsCountDisplay, for: .normal)
            
            cell.motionIdentifier = item.cellMotionIdentifier
            cell.imageView.motionIdentifier = item.imageViewMotionIdentifier
            cell.progressView.motionIdentifier = item.lifeBarMotionIdentifier
            
            cell.userAvatarImageView.motionIdentifier = item.userDisplay?.userImageViewMotionIdentifier
            cell.displayNameLabel.motionIdentifier = item.userDisplay?.displayNameLabelMotionIdentifier
            
            cell.remainTimeLabel.motionIdentifier = item.remainTimeLabelMotionIdentifier
            cell.starButton.motionIdentifier = item.starButtonMotionIdentifier
            DispatchQueue.main.async {
                StarButtonPresenter.isMediumStared(base: cell.starButton).onNext(item.isStared)
            }
        }
    }
}

struct StarButtonPresenter {
    
    static func isMediumStared(base: UIButton) -> Binder<Bool?> {
        return Binder(base) { button, isStared in
            button.isUserInteractionEnabled = isStared != true
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
//                guard let isStared = isStared else {
//                    button.alpha = 0
//                    return
//                }
//                button.alpha =  1
                if isStared == true {
                    button.tintColor = .secondary
                } else {
                    button.tintColor = .gray
                }
            })
        }
    }
    
    static func isSelected(base: UIButton) -> Binder<Bool?> {
        return Binder(base) { button, isSelected in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                guard let isSelected = isSelected else {
                    button.alpha = 0
                    return
                }
                button.alpha =  1
                if isSelected == true {
                    button.tintColor = .secondary
                } else {
                    button.tintColor = .gray
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
