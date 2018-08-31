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
import RealmSwift

final class BlockingsViewController: ShowNavigationBarViewController, IsStateViewController {
    
    @IBOutlet var presenter: BlockingsPresenter!
    
    typealias State = UserBlockingsStateObject
    typealias Event = State.Event

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(), let state = try? State.create()(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryUserBlockings: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.user?.blockingUsers.map { $0.fragments.userFragment } }.forceUnwrap()
        },
            blockUser: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.blockUser }.forceUnwrap()
        },
            unblockUser: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.unblockUser }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        typealias Section = BlockingsPresenter.Section
        return bind(self) { (me, state)  in
            let presenter = me.presenter!
            let _events = PublishRelay<Event>()
            let subscriptions = [
                state.map { [Section(model: "", items: $0.userBlockingsItems())] }.drive(presenter.items(_events)),
                state.map { $0.userBlockingUsersQueryState?.isEmpty ?? false }.drive(presenter.isBlockingsEmpty),
                ]
            let events: [Signal<Event>] = [
                .just(.onTriggerReloadUserBlockings),
                _events.asSignal(),
                presenter.tableView.rx.modelSelected(UserObject.self).asSignal().map { .onTriggerShowUser($0._id) },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension UserBlockingsStateObject {
    
    func userBlockingsItems() -> [UserObject] {
        return userBlockingUsersQueryState?.userBlockings.toArray() ?? []
    }
}
