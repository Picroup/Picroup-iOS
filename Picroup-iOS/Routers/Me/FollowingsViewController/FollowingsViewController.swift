//
//  FollowingsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

final class FollowingsViewController: ShowNavigationBarViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    @IBOutlet var presenter: FollowingsPresenter!
    fileprivate typealias Feedback = (Driver<UserFollowingsStateObject>) -> Signal<UserFollowingsStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard
            let userId = dependency,
            let store = try? UserFollowingsStateStore(userId: userId) else {
                return
        }
        
        typealias Section = FollowingsPresenter.Section
        
        let uiFeedback: Feedback = bind(self) { (me, state)  in
            let presenter = me.presenter!
            let _events = PublishRelay<UserFollowingsStateObject.Event>()
            let subscriptions = [
                state.map { $0.user?.followingsCount.value?.description ?? "0" }.map { "\($0) 人" }.drive(me.navigationItem.detailLabel.rx.text),
                store.userFollowingsItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(_events)),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                state.map { $0.isFollowingsEmpty }.drive(presenter.isFollowingsEmpty),
                ]
            let events: [Signal<UserFollowingsStateObject.Event>] = [
                .just(.onTriggerReloadUserFollowings),
                _events.asSignal(),
                state.flatMapLatest {
                    $0.shouldQueryMoreUserFollowings
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreUserFollowings },
                presenter.tableView.rx.modelSelected(UserObject.self).asSignal().map { .onTriggerShowUser($0._id) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryUserFollowings: Feedback = react(query: { $0.userFollowingsQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.followings }.unwrap()
                .map(UserFollowingsStateObject.Event.onGetUserFollowings(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: UserFollowingsStateObject.Event.onGetUserFollowingsError)
        })
        
        let followUser: Feedback = react(query: { $0.followUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.followUser }.unwrap()
                .map(UserFollowingsStateObject.Event.onFollowUserSuccess)
                .asSignal(onErrorReturnJust: UserFollowingsStateObject.Event.onFollowUserError)
        })
        
        let unfollowUser: Feedback = react(query: { $0.unfollowUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.unfollowUser }.unwrap()
                .map(UserFollowingsStateObject.Event.onUnfollowUserSuccess)
                .asSignal(onErrorReturnJust: UserFollowingsStateObject.Event.onUnfollowUserError)
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryUserFollowings(states),
            followUser(states),
            unfollowUser(states)
            )
            .debug("UserFollowingsState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
    }
}

extension UserFollowingsStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(
            cursor: userFollowings?.cursor.value,
            items: userFollowings?.items,
            trigger: triggerUserFollowingsQuery,
            error: userFollowingsError
        )
    }
}
