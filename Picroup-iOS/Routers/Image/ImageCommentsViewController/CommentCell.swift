//
//  CommentCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

class CommentCell: RxTableViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!

    func configure(with item: CommentObject, onMoreButtonTap: (() -> Void)?) {
        guard !item.isInvalidated else { return }
        userLabel?.text = item.user?.displayName
        contentLabel?.text = item.content
        photoView.setUserAvatar(with: item.user)
        
        if let onMoreButtonTap = onMoreButtonTap {
            moreButton.rx.tap
                .subscribe(onNext: onMoreButtonTap)
                .disposed(by: disposeBag)
        }
    }
}
