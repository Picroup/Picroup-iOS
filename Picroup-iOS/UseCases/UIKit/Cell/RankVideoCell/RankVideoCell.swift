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
import Material

class RankVideoCell: RxCollectionViewCell {
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var starButton: UIButton! {
        didSet { starButton.setImage(Icon.favorite, for: .normal)}
    }
    @IBOutlet weak var remainTimeLabel: UILabel!
//    @IBOutlet weak var starPlaceholderView: UIView!
    
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
            cell.remainTimeLabel.text = viewModel.remainTimeLabelText
            cell.playerView.backgroundColor = viewModel.placeholderColor
            cell.playerView.motionIdentifier = viewModel.imageViewMotionIdentifier
            cell.transition(.fadeOut, .scale(0.75))
            cell.progressView.progress = viewModel.progress
            cell.motionIdentifier = viewModel.cellMotionIdentifier
            cell.progressView.motionIdentifier = viewModel.lifeBarMotionIdentifier
            cell.remainTimeLabel.motionIdentifier = viewModel.remainTimeLabelMotionIdentifier
            cell.starButton.motionIdentifier = viewModel.starPlaceholderViewMotionIdentifier
            StarButtonPresenter.isMediumStared(base: cell.starButton).onNext(viewModel.stared)
        }
    }
}

