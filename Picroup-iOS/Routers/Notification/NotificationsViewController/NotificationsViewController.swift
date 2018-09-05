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
import RealmSwift

final class NotificationsViewController: BaseViewController, IsStateViewController {
    
    @IBOutlet fileprivate var presenter: NotificationsViewPresenter!
    
    typealias State = NotificationsStateObject
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
            queryNotifacations: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.notifications.fragments.cursorNotoficationsFragment }.forceUnwrap()
        },
            queryMark: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData).map { $0?.data?.user?.markNotificationsAsViewed.id }.forceUnwrap()
        })
        .drive()
        .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        typealias Section = NotificationsViewPresenter.Section
        return bind(self) { (me, state)  in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { [Section(model: "", items: $0.notifications())] }.drive(presenter.items),
                state.map { $0.footerState }.drive(onNext: presenter.loadFooterView.on),
                state.map { $0.notificationsQueryState?.isEmpty ?? false }.drive(presenter.isNotificationsEmpty),
                presenter.tableView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                presenter.tableView.rx.shouldHideNavigationBar().emit(to: me.rx.setTabBarHidden(animated: true)),
                ]
            let events: [Signal<NotificationsStateObject.Event>] = [
                .just(.onTriggerReload),
                me.rx.viewWillAppear.asSignal().map { _ in .onTriggerReload },
                state.flatMapLatest {
                    ($0.notificationsQueryState?.shouldQueryMore ?? false)
                        ? presenter.tableView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMore },
                presenter.tableView.rx.modelSelected(NotificationObject.self).asSignal().flatMap { notification in
                    switch (notification.kind, notification.mediumId, notification.userId) {
                    case (NotificationKind.commentMedium.rawValue?, let mediumId?, _):
                        return .just(.onTriggerShowComments(mediumId))
                    case (NotificationKind.starMedium.rawValue?, let mediumId?, _):
                        return .just(.onTriggerShowImage(mediumId))
                    case (NotificationKind.followUser.rawValue?, _, let userId?):
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

extension NotificationsStateObject {
    
    var footerState: LoadFooterViewState {
        return LoadFooterViewState.create(
            cursor: notificationsQueryState?.cursorItemsObject?.cursor.value,
            items: notificationsQueryState?.cursorItemsObject?.items,
            trigger: notificationsQueryState?.trigger ?? false,
            error: notificationsQueryState?.error
        )
    }
    
    func notifications() -> [NotificationObject] {
        return notificationsQueryState?.cursorNotifications?.items.toArray() ?? []
    }
}


