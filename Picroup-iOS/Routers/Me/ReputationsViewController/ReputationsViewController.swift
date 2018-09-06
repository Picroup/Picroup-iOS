//
//  ReputationsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxFeedback
import RealmSwift

class ReputationsViewController: ShowNavigationBarViewController, IsStateViewController {
    
    @IBOutlet fileprivate var presenter: ReputationsViewPresenter!
    
    typealias State = ReputationsStateObject
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
            queryReputations: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.reputationLinks.fragments.cursorReputationLinksFragment }.forceUnwrap()
        },
            queryMark: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.markReputationLinksAsViewed.id }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        typealias Section = ReputationsViewPresenter.Section
        return bind(self) { (me, state)  in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.sessionState?.currentUser?.reputation.value?.description ?? "0" }.drive(me.navigationItem.detailLabel.rx.text),
                state.map { [Section(model: "", items: $0.reputations())] }.drive(presenter.items),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                state.map { $0.reputationsQueryState?.isEmpty ?? false }.drive(presenter.isReputationsEmpty),
                ]
            let events: [Signal<Event>] = [
                .just(.onTriggerReload),
                state.flatMapLatest {
                    ($0.reputationsQueryState?.shouldQueryMore ?? false)
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMore },
                presenter.tableView.rx.modelSelected(ReputationObject.self).asSignal().flatMap { reputation in
                    switch (reputation.kind, reputation.mediumId, reputation.userId) {
                    case ("saveMedium"?, let mediumId?, _):
                        return .just(.onTriggerShowImage(mediumId))
                    case ("starMedium"?, let mediumId?, _):
                        return .just(.onTriggerShowImage(mediumId))
                    case ("followUser"?, _, let userId?):
                        return .just(.onTriggerShowUser(userId))
                    default:
                        return .empty()
                    }
                },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension ReputationsStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(
            cursor: reputationsQueryState?.cursorItemsObject?.cursor.value,
            items: reputationsQueryState?.cursorItemsObject?.items,
            trigger: reputationsQueryState?.trigger ?? false,
            error: reputationsQueryState?.error
        )
    }
    
    func reputations() -> [ReputationObject] {
        return reputationsQueryState?.cursorReputations?.items.toArray() ?? []
    }
}
