//
//  RankVideoCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class RankVideoCell: RxCollectionViewCell {
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var starPlaceholderView: UIView!
    
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
            //        playerView.play(with: item.detail?.videoMinioId)
            cell.playerView.backgroundColor = viewModel.placeholderColor
            cell.playerView.motionIdentifier = viewModel.imageViewMotionIdentifier
            cell.transition(.fadeOut, .scale(0.75))
            cell.progressView.progress = viewModel.progress
            cell.progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
            cell.starPlaceholderView.motionIdentifier = viewModel.starPlaceholderViewMotionIdentifier
        }
    }
}

