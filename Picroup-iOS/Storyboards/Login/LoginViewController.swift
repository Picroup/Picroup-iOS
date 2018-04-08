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
    
    fileprivate var loginViewPresenter: LoginViewPresenter!
    private let disposeBag = DisposeBag()
    private let client = ApolloClient(url: URL(string: "\(Config.baseURL)/graphql")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        loginViewPresenter = LoginViewPresenter(view: view)
        
        typealias Feedback = (Driver<LoginState>) -> Signal<LoginState.Event>

        let uiFeedback: Feedback = bind(loginViewPresenter) { [snackbarController = snackbarController!] (presenter, state) in
            let subscriptions = [
                state.map { $0.username }.distinctUntilChanged().drive(presenter.usernameField.rx.text),
                state.map { $0.password }.distinctUntilChanged().drive(presenter.passwordField.rx.text),
                state.map { $0.shouldHideUseenameWarning }.distinctUntilChanged().drive(presenter.usernameField.detailLabel.rx.isHidden),
                state.map { $0.shouldHidePasswordWarning }.distinctUntilChanged().drive(presenter.passwordField.detailLabel.rx.isHidden),
                state.map { $0.shouldLogin }.distinctUntilChanged().drive(presenter.isLoginEnabled),
                state.map { $0.triggerLogin }.distinctUntilChanged { $0 != nil }.unwrap().mapToVoid().drive(presenter.usernameField.rx.resignFirstResponder()),
                state.map { $0.triggerLogin }.distinctUntilChanged { $0 != nil }.unwrap().mapToVoid().drive(presenter.passwordField.rx.resignFirstResponder()),
                state.map { $0.user }.distinctUntilChanged { $0 != nil }.unwrap().map { _ in "登录成功" }.drive(snackbarController.rx.snackbarText),
                state.map { $0.error }.distinctUntilChanged { $0 != nil }.unwrap().map { $0.localizedDescription }.drive(snackbarController.rx.snackbarText),
            ]
            let events = [
                presenter.usernameField.rx.text.orEmpty.map(LoginState.Event.onChangeUsername),
                presenter.passwordField.rx.text.orEmpty.map(LoginState.Event.onChangePassword),
                presenter.raisedButton.rx.tap.map { LoginState.Event.onTrigger }
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let loginAction: Feedback = react(query: { $0.triggerLogin }) { [client] param in
            let (username, password) = param
            return client.rx.fetch(query: LoginQuery(username: username, password: password))
                .map { $0?.data?.login }.map {
                    guard let snapshot = $0?.snapshot else { throw LoginError.usernameOrPasswordIncorrect }
                    return UserQuery.Data.User(snapshot: snapshot)
                }
                .map(LoginState.Event.onSuccess)
                .asSignal(onErrorRecover: { error in Signal.just(LoginState.Event.onError(error)) })
                .startWith(LoginState.Event.onExecuting)
        }
        
        Driver<Any>.system(
            initialState: LoginState.empty,
            reduce: LoginState.reduce,
            feedback: uiFeedback, loginAction
            )
            .debug("LoginState")
            .drive()
            .disposed(by: disposeBag)
    }
}

private extension LoginState {
    var shouldHideUseenameWarning: Bool {
        return username.isEmpty || isUsernameValid
    }
    
    var shouldHidePasswordWarning: Bool {
        return password.isEmpty || isPasswordValid
    }
}

extension Reactive where Base: SnackbarController {
    var snackbarText: Binder<String> {
        return Binder(base) { snackbarController, text in
            snackbarController.snackbar.text = text
            snackbarController.animate(snackbar: .visible)
            snackbarController.animate(snackbar: .hidden, delay: 4)
        }
    }
}
