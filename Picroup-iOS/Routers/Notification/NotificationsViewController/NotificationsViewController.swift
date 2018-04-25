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
    typealias Feedback = DriverFeedback<NotificationsState>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupPresenter() {
        presenter.setup(navigationItem: navigationItem)
    }
    
    private func setupRxFeedback() {
        
        let uiFeedback = self.uiFeedback
        let queryNotifications = Feedback.queryNotifications(client: ApolloClient.shared)
        let queryMarkNotificationsAsViewed = Feedback.queryMarkNotificationsAsViewed(client: ApolloClient.shared)
        
        
        Driver<Any>.system(
            initialState: NotificationsState.empty(
                userId: Config.userId
            ),
            reduce: logger(identifier: "ReputationsState")(NotificationsState.reduce),
            feedback:
                uiFeedback,
                queryNotifications,
                queryMarkNotificationsAsViewed
            )
            .drive()
            .disposed(by: disposeBag)
        
    }
}

extension NotificationsViewController {
    
    fileprivate var uiFeedback: Feedback.Raw {
        typealias Section = NotificationsViewPresenter.Section
        
        return bind(presenter) { (presenter, state) in
            return Bindings(
                subscriptions: [
                    state.map { [Section(model: "", items: $0.items)] }.drive(presenter.items),
                    ],
                events: [
                    state.flatMapLatest {
                        $0.shouldQueryMore ? presenter.tableView.rx.isNearBottom.asSignal() : .empty()
                        }.map { .onTriggerGetMore },
                    ]
            )
        }
    }
}

