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
        let onStarButtonTap: (() -> Void)?
    }
}


extension ImageDetailCell.ViewModel {
    
    init(item: RankedMediaQuery.Data.RankedMedium.Item, meduim: MediumQuery.Data.Medium?, onStarButtonTap: (() -> Void)?) {
        
        self.imageViewMinioId = item.minioId
        self.imageViewMotionIdentifier = item.id
        self.progress = CGFloat(item.remainTime / 8.0.weeks)
        self.lifeBarMotionIdentifier = "lifeBar_\(item.id)"
        self.starButtonMotionIdentifier = "starButton_\(item.id)"
        self.remainTimeLabelText = "\(Int(item.remainTime / 1.0.weeks))周"
        self.commentsCountLabelText = "\(item.commentsCount)条"
        self.stared = meduim?.stared
        self.onStarButtonTap = onStarButtonTap
    }
}

class ImageDetailCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lifeBar: UIView!
    @IBOutlet weak var starButton: FABButton! {
        didSet {
            contentView.layer.cornerRadius = 5
            contentView.layer.masksToBounds = true
            starButton.image = Icon.favorite
        }
    }
    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    func configure(with viewModel: ViewModel) {
        imageView.setImage(with: viewModel.imageViewMinioId!)
        imageView.motionIdentifier = viewModel.imageViewMotionIdentifier
        lifeBar.motionIdentifier = viewModel.lifeBarMotionIdentifier
        starButton.motionIdentifier = viewModel.starButtonMotionIdentifier
        lifeViewWidthConstraint.constant = viewModel.progress * lifeBar.bounds.width
        remainTimeLabel.text = viewModel.remainTimeLabelText
        commentsCountLabel.text = viewModel.commentsCountLabelText
//        configureStarButton(with: viewModel)
    }
    
    private func configureStarButton(with viewModel: ViewModel) {
        
//        Observable<Int>.timer(0.4, scheduler: MainScheduler.instance)
//            .bind(to: Binder(self) { me, _ in
//                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
//                    me.starButton.alpha = viewModel.stared == nil ? 0 : 1
//                    me.setStarButtonSelected(viewModel.stared == true)
//                })
//            })
//            .disposed(by: disposeBag)
//
//        if let onStarButtonTap = viewModel.onStarButtonTap {
//            starButton.rx.tap
//                .subscribe(onNext: onStarButtonTap)
//                .disposed(by: disposeBag)
//        }
        
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
