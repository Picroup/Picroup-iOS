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

class ReputationsViewController: ShowNavigationBarViewController {
    
    @IBOutlet fileprivate var presenter: ReputationsViewPresenter!
    fileprivate typealias Feedback = (Driver<ReputationsStateObject>) -> Signal<ReputationsStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? ReputationsStateStore() else { return }
        
        typealias Section = ReputationsViewPresenter.Section
        
        let uiFeedback: Feedback = bind(self) { (me, state)  in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.session?.currentUser?.reputation.value?.description ?? "0" }.drive(me.navigationItem.detailLabel.rx.text),
                store.reputations().map { [Section(model: "", items: $0)] }.drive(presenter.items),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                state.map { $0.isReputationsEmpty }.drive(presenter.isReputationsEmpty),
                ]
            let events: [Signal<ReputationsStateObject.Event>] = [
                .just(.onTriggerReload),
                state.flatMapLatest {
                    $0.shouldQueryMoreReputations
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
        
        let queryReputations: Feedback = react(query: { $0.reputationsQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.reputationLinks.fragments.cursorReputationLinksFragment }.unwrap()
                .map(ReputationsStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: ReputationsStateObject.Event.onGetError)
        })
        
        let queryMark: Feedback = react(query: { $0.markQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.markReputationLinksAsViewed.id }.unwrap()
                .map(ReputationsStateObject.Event.onMarkSuccess)
                .asSignal(onErrorReturnJust: ReputationsStateObject.Event.onMarkError)
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryReputations(states),
            queryMark(states)
            )
            .debug("ReputationsState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
    }
}

extension ReputationsStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(
            cursor: reputations?.cursor.value,
            items: reputations?.items,
            trigger: triggerReputationsQuery,
            error: reputationsError
        )
    }
}
