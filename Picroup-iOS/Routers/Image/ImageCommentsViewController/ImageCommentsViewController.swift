//
//  ImageCommentsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

class ImageCommentsViewController: HideNavigationBarViewController {
    
    typealias Dependency = RankedMediaQuery.Data.RankedMedium.Item
    var dependency: Dependency!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        Observable.just([dependency])
            .bind(to: collectionView.rx.items(cellIdentifier: "ImageCommentsDetailCell", cellType: ImageCommentsDetailCell.self)){ index, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
        
        view.rx.tapGesture().when(.recognized).map { _ in }.bind(to: rx.pop(animated: true))
            .disposed(by: disposeBag)
    }
}


class ImageCommentsDetailCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lifeBar: UIView!
    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var starPlaceholderView: UIView!
    @IBOutlet weak var sendButton: FlatButton!
    
    func configure(with item: RankedMediaQuery.Data.RankedMedium.Item) {
        imageView.setImage(with: item.minioId)
        imageView.motionIdentifier = item.id
        lifeBar.motionIdentifier = "lifeBar_\(item.id)"
        sendButton.motionIdentifier = "starButton_\(item.id)"
        lifeViewWidthConstraint.constant = CGFloat(item.endedAt.sinceNow / 8.0.weeks) * lifeBar.bounds.width
        commentsCountLabel.text = "\(item.commentsCount)条"
    }
}
