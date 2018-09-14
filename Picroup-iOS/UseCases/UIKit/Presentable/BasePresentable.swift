//
//  BasePresentable.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

protocol BasePresentable {
    var isInvalidated: Bool { get }
    var _id: String { get }
}
