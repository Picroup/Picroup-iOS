//
//  DispachQueue+realm.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

extension DispatchQueue {
    
    static let realm = DispatchQueue(label: "com.picroup.Picroup-iOS.realm", qos: .userInteractive)
}
