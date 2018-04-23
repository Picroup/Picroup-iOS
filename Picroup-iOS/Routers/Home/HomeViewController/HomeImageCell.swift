//
//  HomeImageCell.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import Material
import RxSwift
import RxCocoa


class HomeImageCell: RxCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var lifeBar: UIView!
    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
}
