//
//  HasMoreButton.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

protocol HasMoreButton {
    var moreButton: UIButton! { get }
}

extension ImageDetailCell: HasMoreButton {}
extension VideoDetailCell: HasMoreButton {}
