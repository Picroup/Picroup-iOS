//
//  SnackbarObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

final class SnackbarObject: VersionedPrimaryObject {
    
    @objc dynamic fileprivate(set) var message: String?
}

extension SnackbarObject {
    
    enum Event {
        case onUpdateMessage(String?)
    }
}

extension SnackbarObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onUpdateMessage(let message):
            self.message = message
            self.updateVersion()
        }
    }
}
