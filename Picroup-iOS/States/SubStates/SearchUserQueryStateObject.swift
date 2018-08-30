//
//  SearchUserQueryStateObject.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/30.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift

final class SearchUserQueryStateObject: PrimaryObject {
    
    @objc dynamic var searchText: String = ""
    @objc dynamic var success: UserObject?
    @objc dynamic var error: String?
    @objc dynamic var trigger: Bool = false
}

extension SearchUserQueryStateObject {
    func query(followedByUserId: String?) -> SearchUserQuery? {
        guard let followedByUserId = followedByUserId, !searchText.isEmpty else { return nil }
        return trigger
            ? SearchUserQuery(username: searchText, followedByUserId: followedByUserId)
            : nil
    }
    var userNotfound: Bool {
        return !searchText.isEmpty
            && !trigger
            && error == nil
            && success == nil
    }
}

extension SearchUserQuery: Equatable {
    public static func ==(lhs: SearchUserQuery, rhs: SearchUserQuery) -> Bool {
        return lhs.username == rhs.username
            && lhs.followedByUserId == rhs.followedByUserId
    }
}

extension SearchUserQueryStateObject {
    
    static func createValues() -> Any {
        let _id = PrimaryKey.default
        return [
            "_id": _id,
        ]
    }
}

extension SearchUserQueryStateObject {
    
    enum Event {
        case onChangeSearchText(String)
        case onSuccess(SearchUserQuery.Data.SearchUser?)
        case onError(Error)
    }
}

extension SearchUserQueryStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeSearchText(let searchText):
            self.searchText = searchText
            success = nil
            let shouldQuery = !searchText.isEmpty
            trigger = shouldQuery
        case .onSuccess(let data):
            success = data.map { realm.create(UserObject.self, value: $0.snapshot, update: true) }
            error = nil
            trigger = false
        case .onError(let error):
            self.error = error.localizedDescription
            trigger = false
            
        }
    }
}
