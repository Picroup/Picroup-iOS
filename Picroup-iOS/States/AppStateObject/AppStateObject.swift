//
//  AppState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import RealmSwift
import RxRealm

final class AppStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var meError: String?
    @objc dynamic var triggerMeQuery: Bool = false
    
    @objc dynamic var previousMediumId: String?
    @objc dynamic var currentMediumId: String?
    @objc dynamic var triggerRecommendMedium = false
}

extension AppStateObject {
    var meQuery: UserQuery? {
        guard let userId = session?.currentUserId else { return nil }
        let next = UserQuery(userId: userId, followedByUserId: "", withFollowed: false)
        return triggerMeQuery ? next : nil
    }
    var me: UserObject? {
        return session?.currentUser
    }
    
    var recommendMediumQuery: RecommendMediumMutation? {
        guard
            let previousMediumId = previousMediumId,
            let currentMediumId = currentMediumId,
            previousMediumId != currentMediumId  else {
                return nil
        }
        let query = RecommendMediumMutation(mediumId: previousMediumId, recommendMediumId: currentMediumId)
        return triggerRecommendMedium ? query : nil
    }
}

extension AppStateObject {
    
    static func create() -> (Realm) throws -> AppStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                ]
            return try realm.update(AppStateObject.self, value: value)
        }
    }
}
