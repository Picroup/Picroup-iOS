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

class ReputationsViewController: UIViewController {
    
    @IBOutlet fileprivate var presenter: ReputationsViewPresenter!
    fileprivate typealias Feedback = (Driver<ReputationsStateObject>) -> Signal<ReputationsStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? ReputationsStateStore() else { return }
        
        typealias Section = ReputationsViewPresenter.Section
        
        
        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let subscriptions = [
                state.map { $0.session?.currentUser?.reputation.value?.description ?? "0" }.drive(presenter.reputationCountLabel.rx.text),
                store.reputations().map { [Section(model: "", items: $0)] }.drive(presenter.items),
                ]
            let events: [Signal<ReputationsStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreReputations
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMore },
                .just(.onTriggerReload),
                presenter.headerView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryReputations: Feedback = react(query: { $0.reputationsQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.reputationLinks.fragments.cursorReputationLinksFragment }.unwrap()
                .map(ReputationsStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: ReputationsStateObject.Event.onGetError)
        }
        
        let queryMark: Feedback = react(query: { $0.markQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.markReputationLinksAsViewed.id }.unwrap()
                .map(ReputationsStateObject.Event.onMarkSuccess)
                .asSignal(onErrorReturnJust: ReputationsStateObject.Event.onMarkError)
        }
        
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
