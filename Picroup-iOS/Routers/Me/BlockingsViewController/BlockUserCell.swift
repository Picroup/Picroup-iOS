//
//  BlockUserCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/8/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

final class BlockUserCell: RxTableViewCell {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var blockButton: RaisedButton!
    
    func configure(with item: UserObject?, onBlockButtonTap: (()-> Void)?) {
        let viewModel = UserViewModel(user: item)
        userAvatarImageView.setUserAvatar(with: item)
        displaynameLabel.text = viewModel.displayName
        usernameLabel.text = viewModel.username
        BlockButtonPresenter.isSelected(base: blockButton).onNext(viewModel.blocked)
        if let onBlockButtonTap = onBlockButtonTap {
            blockButton.rx.tap
                .subscribe(onNext: onBlockButtonTap)
                .disposed(by: disposeBag)
        }
    }
}
