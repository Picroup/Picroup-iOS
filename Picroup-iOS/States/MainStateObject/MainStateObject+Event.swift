//
//  MainStateObject+Event.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift


extension MainStateObject {
    
    enum Event {
    }
}

extension MainStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        
    }
}