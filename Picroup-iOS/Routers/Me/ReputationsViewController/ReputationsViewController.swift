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

    typealias Dependency = Int
    var dependency: Dependency!
    
    @IBOutlet fileprivate var presenter: ReputationsViewPresenter!
    typealias Feedback = DriverFeedback<ReputationsState>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let reputation = dependency else { return }
        
        let injectDependncy = self.injectDependncy(appStore: appStore)
        let uiFeedback = self.uiFeedback
        let queryReputations = Feedback.queryReputations(client: ApolloClient.shared)
        let queryMarkRepotationsAsViewed = Feedback.queryMarkRepotationsAsViewed(client: ApolloClient.shared)

        Driver<Any>.system(
            initialState: ReputationsState.empty(
                reputation: reputation
            ),
            reduce: logger(identifier: "ReputationsState")(ReputationsState.reduce),
            feedback:
                injectDependncy,
                uiFeedback,
                queryReputations,
                queryMarkRepotationsAsViewed
            )
            .drive()
            .disposed(by: disposeBag)
        
        view.rx.tapGesture().when(.recognized).mapToVoid()
            .bind(to: rx.pop(animated: true))
            .disposed(by: disposeBag)
        
    }
}

extension ReputationsViewController {
    
    fileprivate func injectDependncy(appStore: AppStore) -> Feedback.Raw {
        return { _ in
            appStore.state.map { $0.currentUser?.toUser() }.asSignal(onErrorJustReturn: nil).map { .onUpdateCurrentUser($0) }
        }
    }
    
    fileprivate var uiFeedback: Feedback.Raw {
        typealias Section = ReputationsViewPresenter.Section
        
        return bind(presenter) { (presenter, state) in
            return Bindings(
                subscriptions: [
                    state.map { $0.reputation.description }.drive(presenter.reputationCountLabel.rx.text),
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
