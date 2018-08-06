//
//  RankVideoCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

class RankVideoCell: RxCollectionViewCell {
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var progressView: ProgressView!
//    @IBOutlet weak var lifeBar: UIView!
//    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var starPlaceholderView: UIView!
    
    func configure(with item: MediumObject) {
//        if item.isInvalidated { return }
        let viewModel = MediumViewModel(item: item)
        //        playerView.play(with: item.detail?.videoMinioId)
        playerView.backgroundColor = viewModel.placeholderColor
        playerView.motionIdentifier = viewModel.imageViewMotionIdentifier
        transition(.fadeOut, .scale(0.75))
        progressView.progress = viewModel.progress
        progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
//        lifeViewWidthConstraint.constant = viewModel.progress * lifeBar.bounds.width
//        lifeBar.motionIdentifier = viewModel.lifeBarMotionIdentifier
        starPlaceholderView.motionIdentifier = viewModel.starPlaceholderViewMotionIdentifier
    }
}

