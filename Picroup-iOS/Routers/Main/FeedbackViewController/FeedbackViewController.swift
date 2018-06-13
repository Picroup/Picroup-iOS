//
//  FeedbackViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

private func mapKindToTitle(kind: String?) -> String {
    switch kind {
    case FeedbackKind.app.rawValue?: return "应用反馈"
    default: return "举报"
    }
}

final class FeedbackViewController: HideNavigationBarViewController {
    
    @IBOutlet var presenter: FeedbackPresenter!
    fileprivate typealias Feedback = (Driver<FeedbackStateObject>) -> Signal<FeedbackStateObject.Event>
    typealias Dependency = (kind: String?, toUserId: String?, mediumId: String?, commentId: String?)
    var dependency: Dependency!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? FeedbackStateStore(kind: dependency.kind, toUserId: dependency.toUserId, mediumId: dependency.mediumId, commentId: dependency.commentId) else { return }

        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { mapKindToTitle(kind: $0.kind) }.drive(presenter.titleLabel.rx.text),
                state.map { $0.content }.distinctUntilChanged().drive(presenter.textView.rx.text),
                state.map { $0.shouldSaveFeedback }.distinctUntilChanged().drive(presenter.saveButton.rx.isEnabledWithBackgroundColor(.secondary)),
                presenter.saveButton.rx.tap.asSignal().emit(to: presenter.textView.rx.resignFirstResponder()),
                ]
            let events: [Signal<FeedbackStateObject.Event>] = [
                presenter.headerView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
            presenter.textView.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().map(FeedbackStateObject.Event.onChangeContent),
                presenter.saveButton.rx.tap.asSignal().map { FeedbackStateObject.Event.onTriggerSaveFeedback },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let saveAppFeedback: Feedback = react(query: { $0.saveAppFeedbackQuery }, effects: composeEffects(predicate: { [weak self] in self?.isViewAppears ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.saveAppFeedback.id  }.unwrap()
                .map(FeedbackStateObject.Event.onSaveFeedbackSuccess)
                .asSignal(onErrorReturnJust: FeedbackStateObject.Event.onSaveFeedbackError)
        })
        
        let saveUserFeedback: Feedback = react(query: { $0.saveUserFeedbackQuery }, effects: composeEffects(predicate: { [weak self] in self?.isViewAppears ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.saveUserFeedback.id }.unwrap()
                .map(FeedbackStateObject.Event.onSaveFeedbackSuccess)
                .asSignal(onErrorReturnJust: FeedbackStateObject.Event.onSaveFeedbackError)
        })

        let saveMediumFeedback: Feedback = react(query: { $0.saveMediumFeedbackQuery }, effects: composeEffects(predicate: { [weak self] in self?.isViewAppears ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.saveMediumFeedback.id }.unwrap()
                .map(FeedbackStateObject.Event.onSaveFeedbackSuccess)
                .asSignal(onErrorReturnJust: FeedbackStateObject.Event.onSaveFeedbackError)
        })
        
        let saveCommentFeedback: Feedback = react(query: { $0.saveCommentFeedbackQuery }, effects: composeEffects(predicate: { [weak self] in self?.isViewAppears ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.saveCommentFeedback.id }.unwrap()
                .map(FeedbackStateObject.Event.onSaveFeedbackSuccess)
                .asSignal(onErrorReturnJust: FeedbackStateObject.Event.onSaveFeedbackError)
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            saveAppFeedback(states),
            saveUserFeedback(states),
            saveCommentFeedback(states),
            saveMediumFeedback(states)
            )
            .debug("FeedbackState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
    }
}

