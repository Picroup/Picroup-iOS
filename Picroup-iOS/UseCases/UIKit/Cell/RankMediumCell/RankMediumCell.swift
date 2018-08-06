//
//  RankMediumCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

struct MediumViewModel {
    let imageViewMinioId: String?
    let imageViewMotionIdentifier: String?
    let progress: Float
    let kind: String?
    let lifeBarMotionIdentifier: String?
    let starPlaceholderViewMotionIdentifier: String?
    let placeholderColor: UIColor
    
    init(item: MediumObject) {
        guard !item.isInvalidated else {
            self.imageViewMinioId = nil
            self.imageViewMotionIdentifier = nil
            self.progress = 0
            self.kind = nil
            self.lifeBarMotionIdentifier = nil
            self.starPlaceholderViewMotionIdentifier = nil
            self.placeholderColor = .background
            return
        }
        
        let remainTime = item.endedAt.value?.sinceNow ?? 0
        
        self.imageViewMinioId = item.minioId
        self.imageViewMotionIdentifier = item._id
        self.progress = Float(remainTime / 12.0.weeks)
        self.kind = item.kind
        self.lifeBarMotionIdentifier = "lifeBar_\(item._id)"
        self.starPlaceholderViewMotionIdentifier = "starButton_\(item._id)"
        self.placeholderColor = item.placeholderColor
    }
}

class RankMediumCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: ProgressView!
//    @IBOutlet weak var lifeBar: UIView!
//    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var starPlaceholderView: UIView!
    @IBOutlet weak var suggestUpdateLabel: UILabel!
    
    func configure(with item: MediumObject) {
//        if item.isInvalidated { return }
        let viewModel = MediumViewModel(item: item)
        if viewModel.kind == MediumKind.image.rawValue {
            imageView.setImage(with: viewModel.imageViewMinioId)
            suggestUpdateLabel.isHidden = true
        } else {
            imageView.image = nil
            suggestUpdateLabel.isHidden = false
        }
        imageView.backgroundColor = viewModel.placeholderColor
        imageView.motionIdentifier = viewModel.imageViewMotionIdentifier
        transition(.fadeOut, .scale(0.75))
//        progressView.progress = viewModel.progress
//        progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
        progressView.progress = viewModel.progress
        progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
        starPlaceholderView.motionIdentifier = viewModel.starPlaceholderViewMotionIdentifier
    }
    
}

extension MediumObject {
    var placeholderColor: UIColor {
        return detail?.placeholderColor.map { UIColor(hexString: $0) } ?? .background
    }
}
