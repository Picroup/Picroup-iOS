//
//  NotificationsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Apollo
import RxFeedback

class NotificationsViewController: UIViewController {
    
    @IBOutlet fileprivate var presenter: NotificationsViewPresenter! {
        didSet { setupPresenter() }
    }
    typealias Feedback = (Driver<NotificationsStateObject>) -> Signal<NotificationsStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupPresenter() {
        presenter.setup(navigationItem: navigationItem)
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? NotificationsStateStore() else { return }
        
        typealias Section = NotificationsViewPresenter.Section

        let uiFeedback: Feedback = bind(presenter) { (presenter, state)  in
            let subscriptions = [
                store.notifications().map { [Section(model: "", items: $0)] }.drive(presenter.items),
                ]
            let events: [Signal<NotificationsStateObject.Event>] = [
                state.flatMapLatest {
                    $0.shouldQueryMoreNotifications
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                }.map { .onTriggerGetMore },
                Signal.just(NotificationsStateObject.Event.onTriggerReload),
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryNotifacations: Feedback = react(query: { $0.notificationsQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.notifications.fragments.cursorNotoficationsFragment }.unwrap()
                .map(NotificationsStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: NotificationsStateObject.Event.onGetError)
        }
        
        let queryMark: Feedback = react(query: { $0.markQuery }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.markNotificationsAsViewed.id }.unwrap()
                .map(NotificationsStateObject.Event.onMarkSuccess)
                .asSignal(onErrorReturnJust: NotificationsStateObject.Event.onMarkError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryNotifacations(states),
            queryMark(states)
            )
            .debug("NotificationsStateObject.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.tableView.rx.shouldHideNavigationBar()
            .emit(to: rx.setNavigationBarHidden(animated: true))
            .disposed(by: disposeBag)
    }
}


