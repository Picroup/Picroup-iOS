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
import RealmSwift

final class ResetPasswordPresenter: NSObject {
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var resetButton: RaisedButton!
    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        preparePasswordField()
    }
    
    fileprivate func preparePasswordField() {
        passwordField.placeholderActiveColor = .primary
        passwordField.dividerActiveColor = .primary
        passwordField.clearButtonMode = .whileEditing
        passwordField.isVisibilityIconButtonEnabled = true
        //        _ = passwordField.becomeFirstResponder()
    }
}

final class ResetPasswordViewController: BaseViewController, IsStateViewController {
    
    typealias State = ResetPasswordStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate var presenter: ResetPasswordPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let realm = try? Realm(), let state = try? State.create()(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryValidPassword: ValidationService.queryValidPassword(),
            resetPassword: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.resetPassword }.forceUnwrap()
        },
            confirmResetPasswordSuccess: { username in
                return DefaultWireframe.shared.promptFor(title: "重置密码成功", message: "请填写用户名 \(username) 重新登录", preferredStyle: .alert, sender: nil, cancelAction: "好", actions: [])
                    .mapToVoid()
        })
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.resetPasswordParamState?.password ?? "" }.asObservable().take(1).bind(to: presenter.passwordField.rx.text),
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
    }
}

extension ResetPasswordStateObject {
    
    var detail: String {
        if resetPasswordParamState?.password.isEmpty == true {
            return " "
        }
        if passwordValidQueryState?.trigger == true {
            return "正在验证..."
        }
        if let error = passwordValidQueryState?.error {
            return error
        }
        return " "
    }
}
