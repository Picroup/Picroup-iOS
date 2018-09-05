//
//  VersionedPrimaryObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

class VersionedPrimaryObject: PrimaryObject {
    @objc dynamic var version: String?
}

extension VersionedPrimaryObject: Versioned {}
