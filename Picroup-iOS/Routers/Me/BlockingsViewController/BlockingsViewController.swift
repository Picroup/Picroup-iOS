//
//  BlockingsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/8/3.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

final class BlockingsViewController: ShowNavigationBarViewController {
    
    @IBOutlet var presenter: BlockingsPresenter!
    fileprivate typealias Feedback = (Driver<UserBlockingsStateObject>) -> Signal<UserBlockingsStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? UserBlockingsStateStore() else { return }
        
        typealias Section = BlockingsPresenter.Section
        
        let uiFeedback: Feedback = bind(self) { (me, state)  in
            let presenter = me.presenter!
            let _events = PublishRelay<UserBlockingsStateObject.Event>()
            let subscriptions = [
                store.userBlockingsItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(_events)),
                state.map { $0.isBlockingsEmpty }.drive(presenter.isBlockingsEmpty),
                ]
            let events: [Signal<UserBlockingsStateObject.Event>] = [
                .just(.onTriggerReloadUserBlockings),
                _events.asSignal(),
                presenter.tableView.rx.modelSelected(UserObject.self).asSignal().map { .onTriggerShowUser($0._id) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryUserBlockings: Feedback = react(query: { $0.userBlockingsQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user }.unwrap()
                .map(UserBlockingsStateObject.Event.onGetReloadUserFollowings)
                .asSignal(onErrorReturnJust: UserBlockingsStateObject.Event.onGetUserFollowingsError)
        })
        
        let blockUser: Feedback = react(query: { $0.blockUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.blockUser }.unwrap()
                .map(UserBlockingsStateObject.Event.onBlockUserSuccess)
                .asSignal(onErrorReturnJust: UserBlockingsStateObject.Event.onBlockUserError)
        })
        
        let unblockUser: Feedback = react(query: { $0.unblockUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.unblockUser }.unwrap()
                .map(UserBlockingsStateObject.Event.onUnblockUserSuccess)
                .asSignal(onErrorReturnJust: UserBlockingsStateObject.Event.onUnblockUserError)
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryUserBlockings(states),
            blockUser(states),
            unblockUser(states)
            )
            .debug("UserBlockingsState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
    }
}

