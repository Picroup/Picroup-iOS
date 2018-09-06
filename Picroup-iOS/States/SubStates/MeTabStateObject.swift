//
//  MeTabStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/31.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

extension MeTabStateObject {
    
    enum Tab: Int {
        case myMedia
        case myStaredMedia
    }
}

final class MeTabStateObject: PrimaryObject {
    @objc dynamic var selectedIndex: Int = 0
}

extension MeTabStateObject {
    
    static func createValues(id: String) -> Any {
        return ["_id": id]
    }
}

extension MeTabStateObject {
    
    enum Event {
        case onChangeSelectedTab(Tab)
    }
}

extension MeTabStateObject: IsFeedbackStateObject {
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeSelectedTab(let tab):
            selectedIndex = tab.rawValue
        }
    }
}

