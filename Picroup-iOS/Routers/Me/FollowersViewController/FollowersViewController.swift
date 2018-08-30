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
import RealmSwift

class FollowersViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    @IBOutlet var presenter: FollowersPresenter!
    
    typealias State = UserFollowersStateObject
    typealias Event = State.Event
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let userId = dependency,
            let realm = try? Realm(),
            let state = try? State.create(userId: userId)(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryUserFollowers: { query in
                return ApolloClient.shared.rx.fetch(query: query)
                    .map { $0?.data?.user?.followers }.forceUnwrap()
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
        typealias Section = FollowersPresenter.Section
        return bind(self) { (me, state)  in
            let _events = PublishRelay<Event>()
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.user?.followersCount.value?.description ?? "0" }.map { "\($0) 人" }.drive(me.navigationItem.detailLabel.rx.text),
                state.map { [Section(model: "", items: $0.userFollowersItems())] }.drive(presenter.items(_events)),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                state.map { $0.userFollowersQueryState?.isEmpty ?? false }.drive(presenter.isFollowersEmpty),
                ]
            let events: [Signal<Event>] = [
                .just(.onTriggerReloadUserFollowers),
                _events.asSignal(),
                state.flatMapLatest {
                    ($0.userFollowersQueryState?.shouldQueryMore ?? false)
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreUserFollowers },
                presenter.tableView.rx.modelSelected(UserObject.self).asSignal().map { .onTriggerShowUser($0._id) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension UserFollowersStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(
            cursor: userFollowersQueryState?.cursorUsers?.cursor.value,
            items: userFollowersQueryState?.cursorUsers?.items,
            trigger: userFollowersQueryState?.trigger ?? false,
            error: userFollowersQueryState?.error
        )
    }
    
    func userFollowersItems() -> [UserObject] {
        return userFollowersQueryState?.cursorUsers?.items.toArray() ?? []
    }
}
