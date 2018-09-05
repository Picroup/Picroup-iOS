//
//  RouteObjects.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift

final class ImageDetialRouteObject: VersionedPrimaryObject {
    
    @objc dynamic var mediumId: String?
}

final class ImageCommetsRouteObject: VersionedPrimaryObject {
    
    @objc dynamic var mediumId: String?
}

final class TagMediaRouteObject: VersionedPrimaryObject {
    
    @objc dynamic var tag: String?
}

final class UpdateMediumTagsRouteObject: VersionedPrimaryObject {
    
    @objc dynamic var mediumId: String?
}

final class ReputationsRouteObject: VersionedPrimaryObject {}

final class CreateImageRouteObject: VersionedPrimaryObject {
    let mediaItemObjects = List<MediaItemObject>()
}

final class UserRouteObject: VersionedPrimaryObject {
    
    @objc dynamic var userId: String?
}

final class UpdateUserRouteObject: VersionedPrimaryObject {}

final class SearchUserRouteObject: VersionedPrimaryObject {}

final class UserFollowingsRouteObject: VersionedPrimaryObject {
    
    @objc dynamic var userId: String?
}

final class UserFollowersRouteObject: VersionedPrimaryObject {
    
    @objc dynamic var userId: String?
}

final class UserBlockingsRouteObject: VersionedPrimaryObject {}

final class LoginRouteObject: VersionedPrimaryObject {}

final class ResetPasswordRouteObject: VersionedPrimaryObject {}

final class BackToLoginRouteObject: VersionedPrimaryObject {}

final class FeedbackRouteObject: VersionedPrimaryObject {
    @objc dynamic var mediumId: String?
    @objc dynamic var toUserId: String?
    @objc dynamic var commentId: String?
    @objc dynamic var kind: String?
}

final class AboutAppRouteObject: VersionedPrimaryObject {}

extension FeedbackRouteObject {
    func triggerApp() {
        self.kind = FeedbackKind.app.rawValue
        self.mediumId = nil
        self.toUserId = nil
        self.commentId = nil
        self.updateVersion()
    }
    func triggerMedium(mediumId: String) {
        self.kind = FeedbackKind.medium.rawValue
        self.mediumId = mediumId
        self.toUserId = nil
        self.updateVersion()
    }
    func triggerUser(toUserId: String) {
        self.kind = FeedbackKind.user.rawValue
        self.mediumId = nil
        self.toUserId = toUserId
        self.commentId = nil
        self.updateVersion()
    }
    func triggerComment(commentId: String) {
        self.kind = FeedbackKind.comment.rawValue
        self.mediumId = nil
        self.toUserId = nil
        self.commentId = commentId
        self.updateVersion()
    }
}

final class PopRouteObject: VersionedPrimaryObject {}

