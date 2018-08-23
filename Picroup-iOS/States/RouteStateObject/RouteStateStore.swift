//
//  RouteStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

final class RouteStateStore {
    
    let states: Driver<RouteStateObject>
    private let _state: RouteStateObject
    
    init() throws {
        let realm = try Realm()
        let _state = try RouteStateObject.create()(realm)
        let states = Observable.from(object: _state).asDriver(onErrorDriveWith: .empty())
        
        self._state = _state
        self.states = states
    }
    
    func session() -> Driver<UserSessionObject> {
        guard let session = _state.session else { return .empty() }
        return Observable.from(object: session).asDriver(onErrorDriveWith: .empty())
    }
    
    func imageDetialRoute() -> Driver<ImageDetialRouteObject> {
        guard let imageDetialRoute = _state.imageDetialRoute else { return .empty() }
        return Observable.from(object: imageDetialRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func imageCommetsRoute() -> Driver<ImageCommetsRouteObject> {
        guard let imageDetialRoute = _state.imageCommetsRoute else { return .empty() }
        return Observable.from(object: imageDetialRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func tagMediaRoute() -> Driver<TagMediaRouteObject> {
        guard let tagMediaRoute = _state.tagMediaRoute else { return .empty() }
        return Observable.from(object: tagMediaRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func updateMediumTagsRoute() -> Driver<UpdateMediumTagsRouteObject> {
        guard let updateMediumTagsRoute = _state.updateMediumTagsRoute else { return .empty() }
        return Observable.from(object: updateMediumTagsRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func reputationsRoute() -> Driver<ReputationsRouteObject> {
        guard let popRoute = _state.reputationsRoute else { return .empty() }
        return Observable.from(object: popRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func createImageRoute() -> Driver<CreateImageRouteObject> {
        guard let popRoute = _state.createImageRoute else { return .empty() }
        return Observable.from(object: popRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func userRoute() -> Driver<(UserRouteObject, Bool)> {
        guard let userRoute = _state.userRoute else { return .empty() }
        return Observable.from(object: userRoute)
            .map { ($0, self._state.session?.currentUserId == $0.userId) }
            .asDriver(onErrorDriveWith: .empty())
    }
    
    func updateUserRoute() -> Driver<UpdateUserRouteObject> {
        guard let updateUserRoute = _state.updateUserRoute else { return .empty() }
        return Observable.from(object: updateUserRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func userFollowingsRoute() -> Driver<UserFollowingsRouteObject> {
        guard let userFollowingsRoute = _state.userFollowingsRoute else { return .empty() }
        return Observable.from(object: userFollowingsRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func userFollowersRoute() -> Driver<UserFollowersRouteObject> {
        guard let userFollowersRoute = _state.userFollowersRoute else { return .empty() }
        return Observable.from(object: userFollowersRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func searchUserRoute() -> Driver<SearchUserRouteObject> {
        guard let searchUserRoute = _state.searchUserRoute else { return .empty() }
        return Observable.from(object: searchUserRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func userBlockingsRoute() -> Driver<UserBlockingsRouteObject> {
        guard let userBlockingsRoute = _state.userBlockingsRoute else { return .empty() }
        return Observable.from(object: userBlockingsRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func loginRoute() -> Driver<LoginRouteObject> {
        guard let loginRoute = _state.loginRoute else { return .empty() }
        return Observable.from(object: loginRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func resetPasswordRoute() -> Driver<ResetPasswordRouteObject> {
        guard let resetPasswordRoute = _state.resetPasswordRoute else { return .empty() }
        return Observable.from(object: resetPasswordRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func backToLoginRoute() -> Driver<BackToLoginRouteObject> {
        guard let backToLoginRoute = _state.backToLoginRoute else { return .empty() }
        return Observable.from(object: backToLoginRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func feedbackRoute() -> Driver<FeedbackRouteObject> {
        guard let feedbackRoute = _state.feedbackRoute else { return .empty() }
        return Observable.from(object: feedbackRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func aboutAppRoute() -> Driver<AboutAppRouteObject> {
        guard let aboutAppRoute = _state.aboutAppRoute else { return .empty() }
        return Observable.from(object: aboutAppRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func popRoute() -> Driver<PopRouteObject> {
        guard let popRoute = _state.popRoute else { return .empty() }
        return Observable.from(object: popRoute).asDriver(onErrorDriveWith: .empty())
    }
    
    func snackbar() -> Driver<SnackbarObject> {
        guard let snackbar = _state.snackbar else { return .empty() }
        return Observable.from(object: snackbar).asDriver(onErrorDriveWith: .empty())
    }
}
