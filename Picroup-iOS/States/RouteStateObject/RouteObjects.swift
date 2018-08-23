//
//  RouteObjects.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

final class ImageDetialRouteObject: PrimaryObject {
    
    @objc dynamic var mediumId: String?
    @objc dynamic var version: String?
}

final class ImageCommetsRouteObject: PrimaryObject {
    
    @objc dynamic var mediumId: String?
    @objc dynamic var version: String?
}

final class TagMediaRouteObject: PrimaryObject {
    
    @objc dynamic var tag: String?
    @objc dynamic var version: String?
}

final class UpdateMediumTagsRouteObject: PrimaryObject {
    
    @objc dynamic var mediumId: String?
    @objc dynamic var version: String?
}

final class ReputationsRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

final class CreateImageRouteObject: PrimaryObject {
    let mediaItemObjects = List<MediaItemObject>()
    @objc dynamic var version: String?
}

final class UserRouteObject: PrimaryObject {
    
    @objc dynamic var userId: String?
    @objc dynamic var version: String?
}

final class UpdateUserRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

final class SearchUserRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

final class UserFollowingsRouteObject: PrimaryObject {
    
    @objc dynamic var userId: String?
    @objc dynamic var version: String?
}

final class UserFollowersRouteObject: PrimaryObject {
    
    @objc dynamic var userId: String?
    @objc dynamic var version: String?
}

final class UserBlockingsRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

final class LoginRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

final class ResetPasswordRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

final class BackToLoginRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

final class FeedbackRouteObject: PrimaryObject {
    @objc dynamic var mediumId: String?
    @objc dynamic var toUserId: String?
    @objc dynamic var commentId: String?
    @objc dynamic var kind: String?
    @objc dynamic var version: String?
}

final class AboutAppRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

extension FeedbackRouteObject {
    func triggerApp() {
        self.kind = FeedbackKind.app.rawValue
        self.mediumId = nil
        self.toUserId = nil
        self.commentId = nil
        self.version = UUID().uuidString
    }
    func triggerMedium(mediumId: String) {
        self.kind = FeedbackKind.medium.rawValue
        self.mediumId = mediumId
        self.toUserId = nil
        self.version = UUID().uuidString
    }
    func triggerUser(toUserId: String) {
        self.kind = FeedbackKind.user.rawValue
        self.mediumId = nil
        self.toUserId = toUserId
        self.commentId = nil
        self.version = UUID().uuidString
    }
    func triggerComment(commentId: String) {
        self.kind = FeedbackKind.comment.rawValue
        self.mediumId = nil
        self.toUserId = nil
        self.commentId = commentId
        self.version = UUID().uuidString
    }
}

final class PopRouteObject: PrimaryObject {
    @objc dynamic var version: String?
}

final class SnackbarObject: PrimaryObject {
    
    @objc dynamic var message: String?
    @objc dynamic var version: String?
}
