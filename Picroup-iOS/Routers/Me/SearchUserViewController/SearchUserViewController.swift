//
//  SearchUserViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import Apollo
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

final class SearchUserViewController: ShowNavigationBarViewController {
    
    @IBOutlet var presenter: SearchUserPresenter!
    fileprivate typealias Feedback = (Driver<SearchUserStateObject>) -> Signal<SearchUserStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupRxFeedback()
    }
    
    private func setupPresenter() {
        presenter.setup(navigationItem: navigationItem)
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? SearchUserStateStore() else { return }
        
        typealias Section = SearchUserPresenter.Section
        
        let uiFeedback: Feedback = bind(self) { (me, state)  in
            let presenter = me.presenter!
            let _events = PublishRelay<SearchUserStateObject.Event>()
            let subscriptions = [
                state.map { $0.searchText }.asObservable().take(1).bind(to: presenter.searchBar.rx.text),
                store.usersItems().map { [Section(model: "", items: $0)] }.drive(presenter.items(_events)),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.searchBar.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.searchBar.rx.resignFirstResponder()),
                ]
            let events: [Signal<SearchUserStateObject.Event>] = [
                _events.asSignal(),
                presenter.searchBar.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).skip(1).map { .onChangeSearchText($0) },
                presenter.tableView.rx.modelSelected(UserObject.self).asSignal().map { .onTriggerShowUser($0._id) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let searchUser: Feedback = react(query: { $0.searchUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query)
                .map { $0?.data?.searchUser }
                .map(SearchUserStateObject.Event.onSearchUserSuccess)
                .asSignal(onErrorReturnJust: SearchUserStateObject.Event.onSearchUserError)
        })
        
        let followUser: Feedback = react(query: { $0.followUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.followUser }.unwrap()
                .map(SearchUserStateObject.Event.onFollowUserSuccess)
                .asSignal(onErrorReturnJust: SearchUserStateObject.Event.onFollowUserError)
        })
        
        let unfollowUser: Feedback = react(query: { $0.unfollowUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query).asObservable()
                .map { $0?.data?.unfollowUser }.unwrap()
                .map(SearchUserStateObject.Event.onUnfollowUserSuccess)
                .asSignal(onErrorReturnJust: SearchUserStateObject.Event.onUnfollowUserError)
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            searchUser(states),
            followUser(states),
            unfollowUser(states)
            )
            .debug("SearchUserState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension SearchUserStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(searchUser: self)
    }
}
