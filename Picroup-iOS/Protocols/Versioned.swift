//
//  Versioned.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

protocol Versioned: AnyObject {
    var version: String? { get set }
}

extension Versioned {
    
    func updateVersion() {
        version = UUID().uuidString
    }
}
