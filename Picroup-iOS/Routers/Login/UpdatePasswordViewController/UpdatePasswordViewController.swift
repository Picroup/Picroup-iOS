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
import RealmSwift

class UpdatePasswordViewController: BaseViewController {

    @IBOutlet fileprivate var presenter: UpdatePasswordPresenter!
    fileprivate typealias Feedback = (Driver<UpdatePasswordStateObject>) -> Signal<UpdatePasswordStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(), let state = try? UpdatePasswordStateObject.create()(realm) else { return }

        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            querySetPassword: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.user?.setPassword.fragments.userFragment }.forceUnwrap()
        })
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: UpdatePasswordStateObject.DriverFeedback {
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.shouldHideOldPasswordWarning }.distinctUntilChanged().drive(presenter.oldPasswordField.detailLabel.rx.isHidden),
                state.map { $0.shouldHidePasswordWarning }.distinctUntilChanged().drive(presenter.passwordField.detailLabel.rx.isHidden),
                state.map { $0.shouldSetPassword }.distinctUntilChanged().drive(presenter.setPasswordButton.rx.isEnabledWithBackgroundColor(.secondary)),
                presenter.setPasswordButton.rx.tap.asSignal().emit(to: presenter.oldPasswordField.rx.resignFirstResponder()),
                presenter.setPasswordButton.rx.tap.asSignal().emit(to: presenter.passwordField.rx.resignFirstResponder()),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.oldPasswordField.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.oldPasswordField.rx.resignFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.passwordField.rx.resignFirstResponder()),
                ]
            let events: [Signal<UpdatePasswordStateObject.Event>] = [
                presenter.oldPasswordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).distinctUntilChanged().map(UpdatePasswordStateObject.Event.onChangeOldPassword),
                presenter.passwordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).distinctUntilChanged().map(UpdatePasswordStateObject.Event.onChangePassword),
                presenter.setPasswordButton.rx.tap.asSignal().map { .onTriggerSetPassword },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

private extension UpdatePasswordStateObject {
    var shouldHideOldPasswordWarning: Bool {
        guard let oldPassword = userSetPasswordQueryState?.oldPassword, let isOldPasswordValid = userSetPasswordQueryState?.isOldPasswordValid else { return true }
        return oldPassword.isEmpty || isOldPasswordValid
    }
    
    var shouldHidePasswordWarning: Bool {
        guard let password = userSetPasswordQueryState?.password, let isPasswordValid = userSetPasswordQueryState?.isPasswordValid else { return true }
        return password.isEmpty || isPasswordValid
    }
}


