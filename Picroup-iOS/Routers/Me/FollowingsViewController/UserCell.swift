//
//  UserCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

class UserCell: RxTableViewCell {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: RaisedButton!
    
    func configure(with viewModel: UserViewModel, onFollowButtonTap: (()-> Void)?) {
        userAvatarImageView.setImage(with: viewModel.avatarId!)
        displaynameLabel.text = viewModel.username
        usernameLabel.text = viewModel.username
        FollowButtonPresenter.isSelected(base: followButton).onNext(viewModel.followed)
        if let onFollowButtonTap = onFollowButtonTap {
            followButton.rx.tap
                .subscribe(onNext: onFollowButtonTap)
                .disposed(by: disposeBag)
        }
    }
}
