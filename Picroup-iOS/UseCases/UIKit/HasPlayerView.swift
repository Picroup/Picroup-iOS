//
//  HasPlayerView.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

protocol HasPlayerView {
    var playerView: PlayerView! { get }
}

extension RankVideoCell: HasPlayerView {}
extension VideoDetailCell: HasPlayerView {}
