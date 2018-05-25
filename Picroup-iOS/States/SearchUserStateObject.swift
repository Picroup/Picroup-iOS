//
//  SearchUserStateObject.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class SearchUserStateObject: PrimaryObject {
    
    @objc dynamic var session: UserSessionObject?
    
    @objc dynamic var searchText: String = ""
    @objc dynamic var user: UserObject?
    @objc dynamic var searchError: String?
    @objc dynamic var triggerSearchUserQuery: Bool = false
    
    @objc dynamic var followToUserId: String?
    @objc dynamic var followUserError: String?
    @objc dynamic var triggerFollowUserQuery: Bool = false
    
    @objc dynamic var unfollowToUserId: String?
    @objc dynamic var unfollowUserError: String?
    @objc dynamic var triggerUnfollowUserQuery: Bool = false
    
    @objc dynamic var userRoute: UserRouteObject?
}

extension SearchUserStateObject {
    var searchUserQuery: SearchUserQuery? {
        guard let byUserId = session?.currentUser?._id, !searchText.isEmpty else { return nil }
        let next = SearchUserQuery(username: searchText, followedByUserId: byUserId)
        return triggerSearchUserQuery ? next : nil
    }
    var userNotfound: Bool {
        return !searchText.isEmpty
            && !triggerSearchUserQuery
            && searchError == nil
            && user == nil
    }
    
    var shouldFollowUser: Bool {
        return !triggerFollowUserQuery
    }
    var followUserQuery: FollowUserMutation? {
        guard
            let userId = session?.currentUser?._id,
            let toUserId = followToUserId else {
                return nil
        }
        return triggerFollowUserQuery ? FollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
    
    var shouldUnfollowUser: Bool {
        return !triggerUnfollowUserQuery
    }
    var unfollowUserQuery: UnfollowUserMutation? {
        guard
            let userId = session?.currentUser?._id,
            let toUserId = unfollowToUserId else {
                return nil
        }
        return triggerUnfollowUserQuery ? UnfollowUserMutation(userId: userId, toUserId: toUserId) : nil
    }
}

extension SearchUserQuery: Equatable {
    public static func ==(lhs: SearchUserQuery, rhs: SearchUserQuery) -> Bool {
        return lhs.username == rhs.username
            && lhs.followedByUserId == rhs.followedByUserId
    }
}

extension SearchUserStateObject {
    
    static func create() -> (Realm) throws -> SearchUserStateObject {
        return { realm in
            let _id = PrimaryKey.default
            let value: Any = [
                "_id": _id,
                "session": ["_id": _id],
                "userRoute": ["_id": _id],
                ]
            return try realm.update(SearchUserStateObject.self, value: value)
        }
    }
}

extension SearchUserStateObject {
    
    enum Event {
        case onChangeSearchText(String)
        case onSearchUserSuccess(SearchUserQuery.Data.SearchUser?)
        case onSearchUserError(Error)
        
        case onTriggerFollowUser(String)
        case onFollowUserSuccess(FollowUserMutation.Data.FollowUser)
        case onFollowUserError(Error)
        
        case onTriggerUnfollowUser(String)
        case onUnfollowUserSuccess(UnfollowUserMutation.Data.UnfollowUser)
        case onUnfollowUserError(Error)
        
        case onTriggerShowUser(String)
    }
}

extension SearchUserStateObject: IsFeedbackStateObject {
    
    func reduce(event: Event, realm: Realm) {
        switch event {
        case .onChangeSearchText(let searchText):
            self.searchText = searchText
            user = nil
            let shouldQuery = !searchText.isEmpty
            triggerSearchUserQuery = shouldQuery
        case .onSearchUserSuccess(let data):
            user = data.map { realm.create(UserObject.self, value: $0.snapshot, update: true) }
            searchError = nil
            triggerSearchUserQuery = false
        case .onSearchUserError(let error):
            searchError = error.localizedDescription
            triggerSearchUserQuery = false
            
        case .onTriggerFollowUser(let toUserId):
            guard shouldFollowUser else { return }
            followToUserId = toUserId
            followUserError = nil
            triggerFollowUserQuery = true
        case .onFollowUserSuccess(let data):
            realm.create(UserObject.self, value: data.snapshot, update: true)
            followToUserId = nil
            followUserError = nil
            triggerFollowUserQuery = false
            //            guard let medium = medium else { return }
        //            myStaredMedia?.items.insert(medium, at: 0)
        case .onFollowUserError(let error):
            followUserError = error.localizedDescription
            triggerFollowUserQuery = false
            
        case .onTriggerUnfollowUser(let toUserId):
            guard shouldUnfollowUser else { return }
            unfollowToUserId = toUserId
            unfollowUserError = nil
            triggerUnfollowUserQuery = true
        case .onUnfollowUserSuccess(let data):
            realm.create(UserObject.self, value: data.snapshot, update: true)
            unfollowToUserId = nil
            unfollowUserError = nil
            triggerUnfollowUserQuery = false
            //            guard let medium = medium else { return }
        //            myStaredMedia?.items.insert(medium, at: 0)
        case .onUnfollowUserError(let error):
            unfollowUserError = error.localizedDescription
            triggerUnfollowUserQuery = false
            
        case .onTriggerShowUser(let userId):
            userRoute?.userId = userId
            userRoute?.version = UUID().uuidString
        }
    }
}

final class SearchUserStateStore {
    
    let states: Driver<SearchUserStateObject>
    private let _state: SearchUserStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try SearchUserStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func on(event: SearchUserStateObject.Event) {
        Realm.backgroundReduce(ofType: SearchUserStateObject.self, forPrimaryKey: PrimaryKey.default, event: event)
    }
    
    func usersItems() -> Driver<[UserObject]> {
        return states.map {
            guard $0.user != nil else { return [] }
            return [$0.user!]
        }
    }
}


