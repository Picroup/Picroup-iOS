//
//  UserPresentable.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/9/14.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

protocol UserPresentable: BasePresentable {
    var usernameDisplay: String { get }
    var displayNameDisplay: String { get }
    var avatarURL: URL? { get }
    
    var reputationDisplay: String { get }
    var followersCountDisplay: String { get }
    var followingsCountDisplay: String { get }
    var gainedReputationCountDisplay: String { get }
    var isGainedReputationCountHidden: Bool { get }
    
    var userImageViewMotionIdentifier: String? { get }
    var displayNameLabelMotionIdentifier: String? { get }

    var isFollowed: Bool? { get }
    var isBlocked: Bool? { get }
}

extension UserObject: UserPresentable {
    
    var usernameDisplay: String {
        return username.map { "@\($0)" } ?? " "
    }
    
    var displayNameDisplay: String {
        return displayName ?? " "
    }
    
    var avatarURL: URL? {
        return url?.toURL()
    }
    
    var reputationDisplay: String {
        return reputation.value?.description ?? "0"
    }
    
    var followersCountDisplay: String {
        return followersCount.value?.description ?? "0"
    }
    
    var followingsCountDisplay: String {
        return followingsCount.value?.description ?? "0"
    }
    
    var gainedReputationCountDisplay: String {
        return gainedReputation.value.map { "+\($0)" } ?? ""
    }
    
    var isGainedReputationCountHidden: Bool {
        return gainedReputation.value == 0
    }
    
    var isFollowed: Bool? {
        return followed.value
    }
    
    var isBlocked: Bool? {
        return blocked.value
    }
    
    var userImageViewMotionIdentifier: String? {
        return "userImageView.\(_id)"
    }
    
    var displayNameLabelMotionIdentifier: String? {
        return "displayNameLabel.\(_id)"
    }
}
