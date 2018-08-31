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
import RealmSwift

final class FollowingsViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    @IBOutlet var presenter: FollowingsPresenter!
    
    typealias State = UserFollowingsStateObject
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
            queryUserFollowings: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.user?.followings }.forceUnwrap()
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
        typealias Section = FollowingsPresenter.Section
        return bind(self) { (me, state)  in
            let presenter = me.presenter!
            let _events = PublishRelay<Event>()
            let subscriptions = [
                state.map { $0.user?.followingsCount.value?.description ?? "0" }.map { "\($0) 人" }.drive(me.navigationItem.detailLabel.rx.text),
                state.map { [Section(model: "", items: $0.userFollowingsItems())] }.drive(presenter.items(_events)),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                state.map { $0.userFollowingsQueryState?.isEmpty ?? false }.drive(presenter.isFollowingsEmpty),
                ]
            let events: [Signal<Event>] = [
                .just(.onTriggerReloadUserFollowings),
                _events.asSignal(),
                state.flatMapLatest {
                    ($0.userFollowingsQueryState?.shouldQueryMore ?? false)
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreUserFollowings },
                presenter.tableView.rx.modelSelected(UserObject.self).asSignal().map { .onTriggerShowUser($0._id) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension UserFollowingsStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(
            cursor: userFollowingsQueryState?.cursorUsers?.cursor.value,
            items: userFollowingsQueryState?.cursorUsers?.items,
            trigger: userFollowingsQueryState?.trigger ?? false,
            error: userFollowingsQueryState?.error
        )
    }
    
    func userFollowingsItems() -> [UserObject] {
        return userFollowingsQueryState?.cursorUsers?.items.toArray() ?? []
    }
}
