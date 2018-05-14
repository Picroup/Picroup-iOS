//
//  RankMediumCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

extension RankMediumCell {
    
    struct ViewModel {
        let imageViewMinioId: String?
        let imageViewMotionIdentifier: String?
        let progress: Float
        let lifeBarMotionIdentifier: String?
        let starPlaceholderViewMotionIdentifier: String?
        
        init(item: MediumFragment) {
            self.imageViewMinioId = item.minioId
            self.imageViewMotionIdentifier = item.id
            self.progress = Float(item.endedAt.sinceNow / 8.0.weeks)
            self.lifeBarMotionIdentifier = "lifeBar_\(item.id)"
            self.starPlaceholderViewMotionIdentifier = "starButton_\(item.id)"
        }
        
        init(item: MediumObject) {
            self.imageViewMinioId = item.minioId
            self.imageViewMotionIdentifier = item._id
            self.progress = Float(item.endedAt.value?.sinceNow ?? 0 / 8.0.weeks)
            self.lifeBarMotionIdentifier = "lifeBar_\(item._id)"
            self.starPlaceholderViewMotionIdentifier = "starButton_\(item._id)"
        }
    }
}

class RankMediumCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var starPlaceholderView: UIView!
    
    func configure(with viewModel: ViewModel) {
        imageView.setImage(with: viewModel.imageViewMinioId)
        imageView.motionIdentifier = viewModel.imageViewMotionIdentifier
        transition(.fadeOut, .scale(0.75))
        progressView.progress = viewModel.progress
        progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
        starPlaceholderView.motionIdentifier = viewModel.starPlaceholderViewMotionIdentifier
    }
}

