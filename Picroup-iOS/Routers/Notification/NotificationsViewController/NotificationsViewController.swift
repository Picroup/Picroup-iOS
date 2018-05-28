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
                state.map { $0.footerState }.asSignalOnErrorRecoverEmpty().emit(onNext: presenter.loadFooterView.on),
            ]
            let events: [Signal<NotificationsStateObject.Event>] = [
                .just(.onTriggerReload),
                state.flatMapLatest {
                    $0.shouldQueryMoreNotifications
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                }.map { .onTriggerGetMore },
                presenter.tableView.rx.modelSelected(NotificationObject.self).asSignal().flatMap { notification in
                    switch (notification.kind, notification.mediumId, notification.userId) {
                    case ("commentMedium"?, let mediumId?, _):
                        return .just(.onTriggerShowComments(mediumId))
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
            .debug("NotificationsState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.tableView.rx.shouldHideNavigationBar()
            .emit(to: rx.setNavigationBarHidden(animated: true))
            .disposed(by: disposeBag)
    }
}

extension NotificationsStateObject {
    
    var footerState: LoadFooterViewState {
        let (cursor, trigger, error) = (notifications?.cursor.value, triggerNotificationsQuery, notificationsError)
        return LoadFooterViewState.create(cursor: cursor, trigger: trigger, error: error)
    }
}


