//
//  RankMediumCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct MediumViewModel {
    let imageViewURL: String?
    let imageViewMotionIdentifier: String?
    let progress: Float
    let kind: String?
    let lifeBarMotionIdentifier: String?
    let starPlaceholderViewMotionIdentifier: String?
    let placeholderColor: UIColor
    
    init(item: MediumObject) {
        guard !item.isInvalidated else {
            self.imageViewURL = nil
            self.imageViewMotionIdentifier = nil
            self.progress = 0
            self.kind = nil
            self.lifeBarMotionIdentifier = nil
            self.starPlaceholderViewMotionIdentifier = nil
            self.placeholderColor = .background
            return
        }
        
        let remainTime = item.endedAt.value?.sinceNow ?? 0
        
        self.imageViewURL = item.url
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
    @IBOutlet weak var starPlaceholderView: UIView!
    @IBOutlet weak var suggestUpdateLabel: UILabel!
    
    func configure(with item: MediumObject) {
        Observable.from(object: item)
            .asDriverOnErrorRecoverEmpty()
            .drive(rxItem)
            .disposed(by: disposeBag)
    }
    
    private var rxItem: Binder<MediumObject> {
        return Binder(self) { cell, item in
            //        if item.isInvalidated { return }
            let viewModel = MediumViewModel(item: item)
            if viewModel.kind == MediumKind.image.rawValue {
                cell.imageView.setImage(with: viewModel.imageViewURL)
                cell.suggestUpdateLabel.isHidden = true
            } else {
                cell.imageView.image = nil
                cell.suggestUpdateLabel.isHidden = false
            }
            cell.imageView.backgroundColor = viewModel.placeholderColor
            cell.imageView.motionIdentifier = viewModel.imageViewMotionIdentifier
            cell.transition(.fadeOut, .scale(0.75))
            cell.progressView.progress = viewModel.progress
            cell.progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
            cell.starPlaceholderView.motionIdentifier = viewModel.starPlaceholderViewMotionIdentifier
        }
    }
    
}

extension MediumObject {
    var placeholderColor: UIColor {
        return detail?.placeholderColor.map { UIColor(hexString: $0) } ?? .background
    }
}
