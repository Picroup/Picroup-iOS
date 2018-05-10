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
        
        init(item: RankedMediaQuery.Data.RankedMedium.Item) {
            self.imageViewMinioId = item.minioId
            self.imageViewMotionIdentifier = item.id
            self.progress = Float(item.endedAt.sinceNow / 8.0.weeks)
            self.lifeBarMotionIdentifier = "lifeBar_\(item.id)"
            self.starPlaceholderViewMotionIdentifier = "starButton_\(item.id)"
        }
        
        init(item: MyMediaQuery.Data.User.Medium.Item) {
            self.init(item: RankedMediaQuery.Data.RankedMedium.Item(snapshot: item.snapshot))
        }
        
        init(item: ImageDetailState.Item) {
            self.init(item: RankedMediaQuery.Data.RankedMedium.Item(snapshot: item.snapshot))
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

