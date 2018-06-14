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

class LoginViewController: BaseViewController {
    
    @IBOutlet fileprivate var presenter: LoginViewPresenter!
    fileprivate typealias Feedback = (Driver<LoginStateObject>) -> Signal<LoginStateObject.Event>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? LoginStateStore() else { return }
        
        presenter.setup(view: view, navigationItem: navigationItem)
        
        weak var weakSelf = self
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.username }.asObservable().take(1).bind(to: presenter.usernameField.rx.text),
                state.map { $0.password }.asObservable().take(1).bind(to: presenter.passwordField.rx.text),
                state.map { $0.shouldHideUseenameWarning }.distinctUntilChanged().drive(presenter.usernameField.detailLabel.rx.isHidden),
                state.map { $0.shouldHidePasswordWarning }.distinctUntilChanged().drive(presenter.passwordField.detailLabel.rx.isHidden),
                state.map { $0.isLoginButtonEnabled }.distinctUntilChanged().drive(presenter.loginButton.rx.isEnabledWithBackgroundColor(.secondary)),
                presenter.loginButton.rx.tap.asSignal().emit(to: presenter.usernameField.rx.resignFirstResponder()),
                presenter.loginButton.rx.tap.asSignal().emit(to: presenter.passwordField.rx.resignFirstResponder()),
                presenter.registerButton.rx.tap.asSignal().emit(onNext: {
                    let vc = RouterService.Login.registerUsernameViewController()
                    weakSelf?.navigationController?.pushViewController(vc, animated: true)
                })
                ]
            let events: [Signal<LoginStateObject.Event>] = [
                presenter.usernameField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().map(LoginStateObject.Event.onChangeUsername),
                presenter.passwordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().map(LoginStateObject.Event.onChangePassword),
                presenter.loginButton.rx.tap.asSignal().map { .onTriggerLogin },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryLogin: Feedback = react(query: { $0.loginQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.login?.fragments.userDetailFragment }.map {
                    guard let userDetailFragment = $0 else { throw LoginError.usernameOrPasswordIncorrect }
                    return userDetailFragment
                }
                .map(LoginStateObject.Event.onLoginSuccess)
                .asSignal(onErrorReturnJust: LoginStateObject.Event.onLoginError)
        })

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

//extension Reactive where Base: SnackbarController {
//    var snackbarText: Binder<String> {
//        return Binder(base) { snackbarController, text in
////            let undoButton = FlatButton(title: "Undo", titleColor: Color.yellow.base)
////            undoButton.pulseAnimation = .backing
////            undoButton.titleLabel?.font = snackbarController.snackbar.textLabel.font
////            snackbarController.snackbar.rightViews = [undoButton]
//            snackbarController.snackbar.text = text
//            snackbarController.animate(snackbar: .visible)
//            snackbarController.animate(snackbar: .hidden, delay: 2)
//        }
//    }
//}

