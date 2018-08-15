//
//  ResetPasswordViewController.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

final class ResetPasswordPresenter: NSObject {
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var resetButton: RaisedButton!
    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareNavigationItem()
        preparePasswordField()
    }
    
    fileprivate func prepareNavigationItem() {
        //        navigationItem.titleLabel.text = "注册"
        //        navigationItem.titleLabel.textColor = .primaryText
    }
    
    fileprivate func preparePasswordField() {
        passwordField.placeholderActiveColor = .primary
        passwordField.dividerActiveColor = .primary
        passwordField.clearButtonMode = .whileEditing
        passwordField.isVisibilityIconButtonEnabled = true
        //        _ = passwordField.becomeFirstResponder()
    }
}

final class ResetPasswordViewController: BaseViewController {
    
    @IBOutlet fileprivate var presenter: ResetPasswordPresenter!
    fileprivate typealias Feedback = (Driver<ResetPasswordStateObject>) -> Signal<ResetPasswordStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? ResetPasswordStateStore() else { return }
        
        presenter.setup(navigationItem: navigationItem)
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.resetPasswordParam?.password ?? "" }.asObservable().take(1).bind(to: presenter.passwordField.rx.text),
                state.map { $0.isPasswordValid }.distinctUntilChanged().drive(presenter.resetButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.drive(presenter.passwordField.rx.detail),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.passwordField.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.passwordField.rx.resignFirstResponder()),
                ]
            let events: [Signal<ResetPasswordStateObject.Event>] = [
                presenter.passwordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).distinctUntilChanged().map(ResetPasswordStateObject.Event.onChangePassword),
                presenter.resetButton.rx.tap.asSignal().map { .onTriggerResetPassword },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let resetPassword: Feedback = react(query: { $0.resetPasswordQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            return ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.resetPassword }.unwrap()
                .map(ResetPasswordStateObject.Event.onResetPasswordSuccess)
                .asSignal(onErrorReturnJust: ResetPasswordStateObject.Event.onResetPasswordError)
        })
        
        let confirmResetPasswordSuccess: Feedback = react(query: { $0.username }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { username in
            return DefaultWireframe.shared.promptFor(title: "重置密码成功", message: "请填写用户名 \(username) 重新登录", preferredStyle: .alert, sender: nil, cancelAction: "好", actions: [])
                .map { _ in .onConfirmResetPasswordSuccess }
                .asSignalOnErrorRecoverEmpty()
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            resetPassword(states),
            confirmResetPasswordSuccess(states)
            )
            .debug("RegisterPasswordState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension ResetPasswordStateObject {
    
    var detail: String {
        if resetPasswordParam?.password.isEmpty == true {
            return " "
        }
        if !isPasswordValid {
            return "大小写字母加数字，至少需要 8 个字"
        }
        return " "
    }
}
