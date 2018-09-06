//
//  UserViewModel.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/29.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation

struct UserViewModel {
    let username: String
    let displayName: String
    let url: String?
    let reputation: String
    let followersCount: String
    let followingsCount: String
    let gainedReputationCount: String
    let isGainedReputationCountHidden: Bool
    let followed: Bool?
    let blocked: Bool?

    init(user: UserObject?) {
        guard user?.isInvalidated == false else {
            self.username = " "
            self.displayName = " "
            self.url = nil
            self.reputation = "0"
            self.followersCount = "0"
            self.followingsCount = "0"
            self.gainedReputationCount = ""
            self.isGainedReputationCountHidden = true
            self.followed = nil
            self.blocked = nil
            return
        }
        self.username = user.map { "@\($0.username ?? "")" } ?? " "
        self.displayName = user?.displayName ?? " "
        self.url = user?.url
        self.reputation = user?.reputation.value?.description ?? "0"
        self.followersCount = user?.followersCount.value?.description ?? "0"
        self.followingsCount = user?.followingsCount.value?.description ?? "0"
        self.gainedReputationCount = user.map { "+\($0.gainedReputation.value ?? 0)" } ?? ""
        self.isGainedReputationCountHidden = user == nil || user?.gainedReputation.value == 0
        self.followed = user?.followed.value
        self.blocked = user?.blocked.value
    }
}


