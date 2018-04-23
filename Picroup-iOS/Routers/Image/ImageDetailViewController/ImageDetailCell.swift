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

extension ImageDetailCell {
    
    struct ViewModel {
        let imageViewMinioId: String?
        let imageViewMotionIdentifier: String?
        let progress: CGFloat
        let lifeBarMotionIdentifier: String?
        let starButtonMotionIdentifier: String?
        let remainTimeLabelText: String?
        let commentsCountLabelText: String?
        let stared: Bool?
        let animatedChangeProgress: Bool
    }
}

extension ImageDetailCell.ViewModel {
    
    init(imageDetailState state: ImageDetailState) {
        let (item, meduim, staredMedium) = (state.item, state.meduim.data, state.staredMedium.data)
        
        let endAt = staredMedium?.endedAt ?? meduim?.endedAt ?? item.endedAt
        let remainTime = endAt.sinceNow
        
        self.imageViewMinioId = item.minioId
        self.imageViewMotionIdentifier = item.id
        self.progress = CGFloat(remainTime / 8.0.weeks)
        self.lifeBarMotionIdentifier = "lifeBar_\(item.id)"
        self.starButtonMotionIdentifier = "starButton_\(item.id)"
        self.remainTimeLabelText = "\(Int(remainTime / 1.0.weeks)) 周"
        self.commentsCountLabelText = "\(item.commentsCount) 条"
        self.stared = (staredMedium != nil) ? true : meduim?.stared
        self.animatedChangeProgress = item.endedAt != endAt
    }
}

class ImageDetailCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lifeBar: UIView!
    @IBOutlet weak var starButton: FABButton! {
        didSet { starButton.image = Icon.favorite }
    }
    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var commentsContentView: UIView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    func configure(with viewModel: ViewModel, onStarButtonTap: (() -> Void)?, onCommentsTap: (() -> Void)?, onImageViewTap: (() -> Void)?) {
        imageView.setImage(with: viewModel.imageViewMinioId!)
        imageView.motionIdentifier = viewModel.imageViewMotionIdentifier
        lifeBar.motionIdentifier = viewModel.lifeBarMotionIdentifier
        starButton.motionIdentifier = viewModel.starButtonMotionIdentifier
        lifeViewWidthConstraint.constant = viewModel.progress * lifeBar.bounds.width
        remainTimeLabel.text = viewModel.remainTimeLabelText
        configureCommentsContentView(with: viewModel)
        configureStarButton(with: viewModel)
        if viewModel.animatedChangeProgress {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.layoutIfNeeded()
            })
        }
        
        if let onCommentsTap = onCommentsTap {
            commentsContentView.rx.tapGesture().when(.recognized).mapToVoid()
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
    }
    
    private func configureCommentsContentView(with viewModel: ViewModel) {
        commentsCountLabel.text = viewModel.commentsCountLabelText
    }
    
    private func configureStarButton(with viewModel: ViewModel) {
        
        self.starButton.isEnabled = viewModel.stared == false

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.starButton.alpha = viewModel.stared == nil ? 0 : 1
            self.setStarButtonSelected(viewModel.stared == true)
        })
        
    }
    
    private func setStarButtonSelected(_ isSelected: Bool) {
        if !isSelected {
            starButton.backgroundColor = .primaryText
            starButton.tintColor = .secondary
        } else {
            starButton.backgroundColor = .secondary
            starButton.tintColor = .primaryText
        }
    }
}
