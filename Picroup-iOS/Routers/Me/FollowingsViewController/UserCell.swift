//
//  UserCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

final class UserCell: RxTableViewCell {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: RaisedButton!
    
    func configure(with item: UserPresentable?, onFollowButtonTap: (()-> Void)?) {
        guard let item = item, !item.isInvalidated else {
            return
        }
        userAvatarImageView.setUserAvatar(with: item)
        displaynameLabel.text = item.displayNameDisplay
        usernameLabel.text = item.usernameDisplay
        FollowButtonPresenter.isSelected(base: followButton).onNext(item.isFollowed)
        
        if let onFollowButtonTap = onFollowButtonTap {
            followButton.rx.tap
                .subscribe(onNext: onFollowButtonTap)
                .disposed(by: disposeBag)
        }
    }
}
