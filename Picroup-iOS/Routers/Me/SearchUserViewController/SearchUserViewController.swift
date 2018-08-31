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
import RealmSwift

final class SearchUserViewController: ShowNavigationBarViewController, IsStateViewController {
    
    @IBOutlet var presenter: SearchUserPresenter!
    
    typealias State = SearchUserStateObject
    typealias Event = State.Event

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupRxFeedback()
    }
    
    private func setupPresenter() {
        presenter.setup(navigationItem: navigationItem)
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(), let state = try? State.create()(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            searchUser: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.searchUser }
        },
            followUser: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.followUser }.forceUnwrap()
        },
            unfollowUser: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.unfollowUser }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        typealias Section = SearchUserPresenter.Section
        return bind(self) { (me, state)  in
            let presenter = me.presenter!
            let _events = PublishRelay<Event>()
            let subscriptions = [
                state.map { $0.searchUserQueryState?.searchText }.asObservable().take(1).bind(to: presenter.searchBar.rx.text),
                state.map { [Section(model: "", items: $0.usersItems())] }.drive(presenter.items(_events)),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.searchBar.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.searchBar.rx.resignFirstResponder()),
                ]
            let events: [Signal<Event>] = [
                _events.asSignal(),
                presenter.searchBar.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).skip(1).distinctUntilChanged().map { .onChangeSearchText($0) },
                presenter.tableView.rx.modelSelected(UserObject.self).asSignal().map { .onTriggerShowUser($0._id) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension SearchUserStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(searchUser: self)
    }
    
    func usersItems() -> [UserObject] {
        guard let user = searchUserQueryState?.success else { return [] }
        return [user]
    }
}

extension LoadFooterViewState {
    
    static func create(searchUser: SearchUserStateObject) -> LoadFooterViewState {
        let trigger = searchUser.searchUserQueryState?.trigger ?? false
        let searchText = searchUser.searchUserQueryState?.searchText ?? ""
        let user = searchUser.searchUserQueryState?.success
        if trigger {
            return .loading
        }
        if !searchText.isEmpty && !trigger  && user == nil {
            return .message("💁🏻‍♀️ 无此人")
        }
        return .empty
    }
}
