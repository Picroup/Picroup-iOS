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
    
    init(dependency: (ApolloClient, (UserQuery.Data.User) -> Void)) {
        self.dependency = dependency
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias Feedback = (Driver<LoginState>) -> Signal<LoginState.Event>
    
    let dependency: (ApolloClient, (UserQuery.Data.User) -> Void)
    
    fileprivate var loginViewPresenter: LoginViewPresenter!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        guard let (client, observer) = dependency else { return }
        let (client, observer) = dependency
        
        loginViewPresenter = LoginViewPresenter(view: view)
        
        let uiFeedback: Feedback = bind(loginViewPresenter) { [snackbarController = snackbarController!] (presenter, state) in
            let subscriptions = [
                state.map { $0.username }.distinctUntilChanged().drive(presenter.usernameField.rx.text),
                state.map { $0.password }.distinctUntilChanged().drive(presenter.passwordField.rx.text),
                state.map { $0.shouldHideUseenameWarning }.distinctUntilChanged().drive(presenter.usernameField.detailLabel.rx.isHidden),
                state.map { $0.shouldHidePasswordWarning }.distinctUntilChanged().drive(presenter.passwordField.detailLabel.rx.isHidden),
                state.map { $0.shouldLogin }.distinctUntilChanged().drive(presenter.raisedButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.triggerLogin }.distinctUnwrap().mapToVoid().drive(presenter.usernameField.rx.resignFirstResponder()),
                state.map { $0.triggerLogin }.distinctUnwrap().mapToVoid().drive(presenter.passwordField.rx.resignFirstResponder()),
                state.map { $0.user }.distinctUnwrap().map { _ in "登录成功" }.drive(snackbarController.rx.snackbarText),
                state.map { $0.error }.distinctUnwrap().map { $0.localizedDescription }.drive(snackbarController.rx.snackbarText),
                state.map { $0.user }.distinctUnwrap().drive(onNext: observer),
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
        }
        
        Driver<Any>.system(
            initialState: LoginState.empty,
            reduce: logger(identifier: "LoginState")(LoginState.reduce),
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
//            let undoButton = FlatButton(title: "Undo", titleColor: Color.yellow.base)
//            undoButton.pulseAnimation = .backing
//            undoButton.titleLabel?.font = snackbarController.snackbar.textLabel.font
//            snackbarController.snackbar.rightViews = [undoButton]
            snackbarController.snackbar.text = text
            snackbarController.animate(snackbar: .visible)
            snackbarController.animate(snackbar: .hidden, delay: 3)
        }
    }
}
