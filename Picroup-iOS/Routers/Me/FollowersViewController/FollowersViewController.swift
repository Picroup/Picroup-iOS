//
//  FollowersViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

class FollowersViewController: HideNavigationBarViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    @IBOutlet var presenter: FollowersPresenter!
    fileprivate typealias Feedback = (Driver<UserFollowersStateObject>) -> Signal<UserFollowersStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard
            let userId = dependency,
            let store = try? UserFollowersStateStore(userId: userId) else {
                return
        }
        
        typealias Section = FollowersPresenter.Section
        
        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let _events = PublishRelay<UserFollowersStateObject.Event>()
            let subscriptions = [
                state.map { $0.user?.followersCount.value?.description ?? "0" }.drive(presenter.followersCountLabel.rx.text),
                store.userFollowersItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(_events)),
                ]
            let events: [Signal<UserFollowersStateObject.Event>] = [
                .just(.onTriggerReloadUserFollowers),
                _events.asSignal(),
                state.flatMapLatest {
                    $0.shouldQueryMoreUserFollowers
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreUserFollowers },
                presenter.tableView.rx.modelSelected(UserObject.self).asSignal().map { .onTriggerShowUser($0._id) },
                presenter.headerView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryUserFollowers: Feedback = react(query: { $0.userFollowersQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.followers }.unwrap()
                .map(UserFollowersStateObject.Event.onGetUserFollowers(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: UserFollowersStateObject.Event.onGetUserFollowersError)
        }
        
        let followUser: Feedback = react(query: { $0.followUserQuery }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.followUser }.unwrap()
                .map(UserFollowersStateObject.Event.onFollowUserSuccess)
                .asSignal(onErrorReturnJust: UserFollowersStateObject.Event.onFollowUserError)
        }
        
        let unfollowUser: Feedback = react(query: { $0.unfollowUserQuery }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.unfollowUser }.unwrap()
                .map(UserFollowersStateObject.Event.onUnfollowUserSuccess)
                .asSignal(onErrorReturnJust: UserFollowersStateObject.Event.onUnfollowUserError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryUserFollowers(states),
            followUser(states),
            unfollowUser(states)
            )
            .debug("UserFollowersState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}
