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
import Material


class RankMediumCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var starButton: UIButton! {
        didSet { starButton.setImage(Icon.favorite, for: .normal)}
    }
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var suggestUpdateLabel: UILabel!
    
    func configure(
        with item: MediumPresentable,
        onStarButtonTap: ((String) -> Void)?
        ) {
        
        if item.isInvalidated { return }
        
        item.asDriver()
            .drive(rxItem)
            .disposed(by: disposeBag)
        
        let mediumId = item._id
        
        if let onStarButtonTap = onStarButtonTap {
            starButton.rx.tap
                .subscribe(onNext: { onStarButtonTap(mediumId) })
                .disposed(by: disposeBag)
        }
    }
    
    private var rxItem: Binder<MediumPresentable> {
        return Binder(self) { cell, item in
            if item.mediumKind == MediumKind.image {
                cell.imageView.setImage(with: item.imageURL)
                cell.suggestUpdateLabel.isHidden = true
            } else {
                cell.imageView.image = nil
                cell.suggestUpdateLabel.isHidden = false
            }
            cell.remainTimeLabel.text = item.remainTimeDisplay
            cell.imageView.backgroundColor = item.placeholderColor
            cell.imageView.motionIdentifier = item.imageViewMotionIdentifier
            cell.progressView.progress = item.lifeProgress
            cell.motionIdentifier = item.cellMotionIdentifier
            cell.progressView.motionIdentifier = item.lifeBarMotionIdentifier
            cell.remainTimeLabel.motionIdentifier = item.remainTimeLabelMotionIdentifier
            cell.starButton.motionIdentifier = item.starButtonMotionIdentifier
            StarButtonPresenter.isMediumStared(base: cell.starButton).onNext(item.isStared)
            cell.transition(.fadeOut, .scale(0.75))
        }
    }
    
}

extension MediumObject {
    var placeholderColor: UIColor {
        return detail?.placeholderColor.map { UIColor(hexString: $0) } ?? .background
    }
}
