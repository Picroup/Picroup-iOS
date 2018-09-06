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
import RealmSwift

private func mapKindToTitle(kind: String?) -> String {
    switch kind {
    case FeedbackKind.app.rawValue?: return "应用反馈"
    default: return "举报"
    }
}

final class FeedbackViewController: ShowNavigationBarViewController, IsStateViewController {
    
    @IBOutlet var presenter: FeedbackPresenter!
    
    typealias State = FeedbackStateObject
    typealias Event = State.Event
    
    typealias Dependency = (kind: String?, toUserId: String?, mediumId: String?, commentId: String?)
    var dependency: Dependency!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(),
            let state = try? State.create(kind: dependency.kind, toUserId: dependency.toUserId, mediumId: dependency.mediumId, commentId: dependency.commentId)(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            saveAppFeedback: { query in
               return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.saveAppFeedback.id  }.forceUnwrap()
        },
            saveUserFeedback: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.saveUserFeedback.id }.forceUnwrap()
        },
            saveMediumFeedback: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.saveMediumFeedback.id }.forceUnwrap()
        },
            saveCommentFeedback: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.saveCommentFeedback.id }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { mapKindToTitle(kind: $0.saveFeedbackQueryState?.kind) }.drive(me.navigationItem.titleLabel.rx.text),
                state.map { $0.saveFeedbackQueryState?.content }.distinctUntilChanged().drive(presenter.textView.rx.text),
                state.map { $0.saveFeedbackQueryState?.shouldQuery ?? false }.distinctUntilChanged().drive(presenter.saveButton.rx.isEnabledWithBackgroundColor(.secondary)),
                presenter.saveButton.rx.tap.asSignal().emit(to: presenter.textView.rx.resignFirstResponder()),
                ]
            let events: [Signal<Event>] = [
                //                presenter.headerView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                presenter.textView.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().map(Event.onChangeContent),
                presenter.saveButton.rx.tap.asSignal().map { .onTriggerSaveFeedback },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

