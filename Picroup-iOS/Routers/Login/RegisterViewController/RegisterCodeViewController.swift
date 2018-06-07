//
//  RegisterCodeViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/6.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

final class RegisterCodePresenter: NSObject {
    @IBOutlet weak var codeField: TextField!
    @IBOutlet weak var validButton: RaisedButton!
    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareNavigationItem()
        prepareUsernameField()
    }
    
    fileprivate func prepareNavigationItem() {
//        navigationItem.titleLabel.text = "注册"
//        navigationItem.titleLabel.textColor = .primaryText
    }
    
    fileprivate func prepareUsernameField() {
        codeField.isClearIconButtonEnabled = true
        codeField.placeholderActiveColor = .primary
        codeField.dividerActiveColor = .primary
        codeField.autocapitalizationType = .none
        _ = codeField.becomeFirstResponder()
    }
}

final class RegisterCodeViewController: UIViewController {
    
    @IBOutlet fileprivate var presenter: RegisterCodePresenter!
    fileprivate typealias Feedback = (Driver<RegisterCodeStateObject>) -> Signal<RegisterCodeStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? RegisterCodeStateStore() else { return }

        presenter.setup(navigationItem: navigationItem)

        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.isRegisterEnabled }.distinctUntilChanged().drive(presenter.validButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.drive(presenter.codeField.rx.detail),
                presenter.validButton.rx.tap.asSignal().emit(to: presenter.codeField.rx.resignFirstResponder()),
                ]
            let events: [Signal<RegisterCodeStateObject.Event>] = [
//                .just(.onTriggerGetVerifyCode),
                presenter.codeField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).map(RegisterCodeStateObject.Event.onChangeCode),
                presenter.validButton.rx.tap.asSignal().map { RegisterCodeStateObject.Event.onTriggerRegister },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }

        let register: Feedback = react(query: { $0.registerQuery }) { query in
            return ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.register.fragments.userDetailFragment }.unwrap()
                .map(RegisterCodeStateObject.Event.onRegisterSuccess)
                .asSignal(onErrorReturnJust: RegisterCodeStateObject.Event.onRegisterError)
        }
        
        let getVerifyCode: Feedback = react(query: { $0.getVerifyCodeQuery }) { query in
            return ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.getVerifyCode }.unwrap()
                .map(RegisterCodeStateObject.Event.onGetVerifyCodeSuccess)
                .asSignal(onErrorReturnJust: RegisterCodeStateObject.Event.onGetVerifyCodeError)
        }

        let states = store.states
            .debug("RegisterCodeState")

        Signal.merge(
            uiFeedback(states),
            register(states),
            getVerifyCode(states)
            )
            .debug("RegisterCodeState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension RegisterCodeStateObject {
    
    fileprivate var isRegisterEnabled: Bool {
        return isCodeAvaliable && !triggerRegisterQuery
    }
    
    fileprivate var detail: String {
        return phoneNumber != nil ? "已发送 6 位数验证码" : " "
    }
}
