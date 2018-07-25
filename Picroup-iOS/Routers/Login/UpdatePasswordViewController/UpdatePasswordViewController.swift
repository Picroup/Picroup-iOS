//
//  UpdatePasswordViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/7.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

final class UpdatePasswordPresenter: NSObject {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var oldPasswordField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var setPasswordButton: RaisedButton!
    
    func setup() {
        prepareOldPasswordField()
        preparePasswordField()
    }
    
    fileprivate func prepareOldPasswordField() {
        oldPasswordField.placeholderActiveColor = .primary
        oldPasswordField.dividerActiveColor = .primary
        oldPasswordField.clearButtonMode = .whileEditing
        oldPasswordField.isVisibilityIconButtonEnabled = true
//        _ = oldPasswordField.becomeFirstResponder()
    }
    
    fileprivate func preparePasswordField() {
        passwordField.placeholderActiveColor = .primary
        passwordField.dividerActiveColor = .primary
        passwordField.clearButtonMode = .whileEditing
        passwordField.isVisibilityIconButtonEnabled = true
    }
}

class UpdatePasswordViewController: BaseViewController {

    @IBOutlet fileprivate var presenter: UpdatePasswordPresenter!
    fileprivate typealias Feedback = (Driver<UpdatePasswordStateObject>) -> Signal<UpdatePasswordStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? UpdatePasswordStateStore() else { return }

        presenter.setup()

        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.shouldHideOldPasswordWarning }.distinctUntilChanged().drive(presenter.oldPasswordField.detailLabel.rx.isHidden),
                state.map { $0.shouldHidePasswordWarning }.distinctUntilChanged().drive(presenter.passwordField.detailLabel.rx.isHidden),
                state.map { $0.shouldSetPassword }.distinctUntilChanged().drive(presenter.setPasswordButton.rx.isEnabledWithBackgroundColor(.secondary)),
                presenter.setPasswordButton.rx.tap.asSignal().emit(to: presenter.oldPasswordField.rx.resignFirstResponder()),
                presenter.setPasswordButton.rx.tap.asSignal().emit(to: presenter.passwordField.rx.resignFirstResponder()),
                ]
            let events: [Signal<UpdatePasswordStateObject.Event>] = [
                presenter.oldPasswordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).map(UpdatePasswordStateObject.Event.onChangeOldPassword),
                presenter.passwordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).map(UpdatePasswordStateObject.Event.onChangePassword),
                presenter.setPasswordButton.rx.tap.asSignal().map { .onTriggerSetPassword },
                presenter.headerView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let querySetPassword: Feedback = react(query: { $0.setPasswordQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.user?.setPassword.fragments.userFragment }.unwrap()
                .map(UpdatePasswordStateObject.Event.onSetPasswordSuccess)
                .asSignal(onErrorReturnJust: UpdatePasswordStateObject.Event.onSetPasswordError)
        })

        let states = store.states

        Signal.merge(
            uiFeedback(states),
            querySetPassword(states)
            )
            .debug("UpdatePasswordState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

private extension UpdatePasswordStateObject {
    var shouldHideOldPasswordWarning: Bool {
        return oldPassword.isEmpty || isOldPasswordValid
    }
    
    var shouldHidePasswordWarning: Bool {
        return password.isEmpty || isPasswordValid
    }
}


