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
import RealmSwift

final class LoginViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias State = LoginStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate var presenter: LoginViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(view: view, navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(), let state = try? State.create()(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryLogin: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.login?.fragments.userDetailFragment }.map {
                        guard let userDetailFragment = $0 else { throw LoginError.usernameOrPasswordIncorrect }
                        return userDetailFragment
                }
        })
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    var uiFeedback: State.DriverFeedback {
        weak var weakSelf = self
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.loginQueryState?.username }.asObservable().take(1).bind(to: presenter.usernameField.rx.text),
                state.map { $0.loginQueryState?.password }.asObservable().take(1).bind(to: presenter.passwordField.rx.text),
                state.map { $0.shouldHideUsernameWarning }.distinctUntilChanged().drive(presenter.usernameField.detailLabel.rx.isHidden),
                state.map { $0.shouldHidePasswordWarning }.distinctUntilChanged().drive(presenter.passwordField.detailLabel.rx.isHidden),
//                state.map { $0.shouldHideForgetPasswordButton }.distinctUntilChanged().drive(presenter.forgetPasswordButton.rx.isHidden),
                state.map { $0.isLoginButtonEnabled }.distinctUntilChanged().drive(presenter.loginButton.rx.isEnabledWithBackgroundColor(.secondary)),
                presenter.loginButton.rx.tap.asSignal().emit(to: presenter.usernameField.rx.resignFirstResponder()),
                presenter.loginButton.rx.tap.asSignal().emit(to: presenter.passwordField.rx.resignFirstResponder()),
                presenter.registerButton.rx.tap.asSignal().emit(onNext: {
                    let vc = RouterService.Login.registerUsernameViewController()
                    weakSelf?.navigationController?.pushViewController(vc, animated: true)
                }),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.usernameField.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.usernameField.rx.resignFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.passwordField.rx.resignFirstResponder()),
                ]
            let events: [Signal<Event>] = [
                presenter.usernameField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().map(Event.onChangeUsername),
                presenter.passwordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().map(Event.onChangePassword),
                presenter.loginButton.rx.tap.asSignal().map { .onTriggerLogin },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

private extension LoginStateObject {
    var shouldHideUsernameWarning: Bool {
        guard let username = loginQueryState?.username, let isUsernameValid = loginQueryState?.isUsernameValid else { return true }
        return username.isEmpty || isUsernameValid
    }
    
    var shouldHidePasswordWarning: Bool {
        guard let password = loginQueryState?.password, let isPasswordValid = loginQueryState?.isPasswordValid else { return true }
        return password.isEmpty || isPasswordValid
    }
//    var shouldHideForgetPasswordButton: Bool {
//        guard let password = loginQueryState?.password else { return true }
//        return !password.isEmpty
//    }
    var isLoginButtonEnabled: Bool {
        guard let shouldLogin = loginQueryState?.shouldLogin, let trigger = loginQueryState?.trigger else { return true }
        return shouldLogin && !trigger
    }
}
