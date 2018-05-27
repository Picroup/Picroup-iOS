//
//  LoginViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

class LoginViewController: UIViewController {
    
    fileprivate var presenter: LoginViewPresenter!
    fileprivate typealias Feedback = (Driver<LoginStateObject>) -> Signal<LoginStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? LoginStateStore() else { return }
        
        presenter = LoginViewPresenter(view: view)
        
        let uiFeedback: Feedback = bind(self) { [snackbarController = snackbarController!] (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.username }.distinctUntilChanged().drive(presenter.usernameField.rx.text),
                state.map { $0.password }.distinctUntilChanged().drive(presenter.passwordField.rx.text),
                state.map { $0.shouldHideUseenameWarning }.distinctUntilChanged().drive(presenter.usernameField.detailLabel.rx.isHidden),
                state.map { $0.shouldHidePasswordWarning }.distinctUntilChanged().drive(presenter.passwordField.detailLabel.rx.isHidden),
                state.map { $0.isLoginButtonEnabled }.distinctUntilChanged().drive(presenter.raisedButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.triggerLoginQuery }.distinctUntilChanged().mapToVoid().drive(presenter.usernameField.rx.resignFirstResponder()),
                state.map { $0.triggerLoginQuery }.distinctUntilChanged().mapToVoid().drive(presenter.passwordField.rx.resignFirstResponder()),
                state.map { $0.session?.currentUser }.distinctUnwrap().map { _ in "登录成功" }.drive(snackbarController.rx.snackbarText),
                state.map { $0.loginError }.distinctUnwrap().drive(snackbarController.rx.snackbarText),
                state.map { $0.session?.currentUser }.distinctUnwrap().mapToVoid().delay(2.3).drive(me.rx.dismiss(animated: true)),
                presenter.closeButton.rx.tap.bind(to: me.rx.dismiss(animated: true))
                ]
            let events: [Signal<LoginStateObject.Event>] = [
                presenter.usernameField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().map(LoginStateObject.Event.onChangeUsername),
                presenter.passwordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().map(LoginStateObject.Event.onChangePassword),
                presenter.raisedButton.rx.tap.asSignal().map { LoginStateObject.Event.onTriggerLogin }
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryLogin: Feedback = react(query: { $0.loginQuery }) { query in
            return ApolloClient.shared.rx.fetch(query: query)
                .map { $0?.data?.login?.fragments.userDetailFragment }.map {
                    guard let userDetailFragment = $0 else { throw LoginError.usernameOrPasswordIncorrect }
                    return userDetailFragment
                }
                .map(LoginStateObject.Event.onLoginSuccess)
                .asSignal(onErrorReturnJust: LoginStateObject.Event.onLoginError)
        }

        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryLogin(states)
            )
            .debug("LoginState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
    }
}

private extension LoginStateObject {
    var shouldHideUseenameWarning: Bool {
        return username.isEmpty || isUsernameValid
    }
    
    var shouldHidePasswordWarning: Bool {
        return password.isEmpty || isPasswordValid
    }
    
    var isLoginButtonEnabled: Bool {
        return shouldLogin && !triggerLoginQuery
    }
}

extension Reactive where Base: SnackbarController {
    var snackbarText: Binder<String> {
        return Binder(base) { snackbarController, text in
//            let undoButton = FlatButton(title: "Undo", titleColor: Color.yellow.base)
//            undoButton.pulseAnimation = .backing
//            undoButton.titleLabel?.font = snackbarController.snackbar.textLabel.font
//            snackbarController.snackbar.rightViews = [undoButton]
            snackbarController.snackbar.text = text
            snackbarController.animate(snackbar: .visible)
            snackbarController.animate(snackbar: .hidden, delay: 2)
        }
    }
}
