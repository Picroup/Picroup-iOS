//
//  ResetPasswordCodeViewController.swift
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

final class ResetPasswordCodePresenter: NSObject {
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
        //        _ = codeField.becomeFirstResponder()
    }
}

final class ResetPasswordCodeViewController: BaseViewController {
    
    @IBOutlet fileprivate var presenter: ResetPasswordCodePresenter!
    fileprivate typealias Feedback = (Driver<ResetPasswordCodeStateObject>) -> Signal<ResetPasswordCodeStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? ResetPasswordCodeStateStore() else { return }
        
        presenter.setup(navigationItem: navigationItem)
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.isResetPasswordEnabled }.distinctUntilChanged().drive(presenter.validButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.drive(presenter.codeField.rx.detail),
                presenter.validButton.rx.tap.asSignal().emit(to: presenter.codeField.rx.resignFirstResponder()),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.codeField.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.codeField.rx.resignFirstResponder()),
                ]
            let events: [Signal<ResetPasswordCodeStateObject.Event>] = [
                .just(.onTriggerGetVerifyCode),
                presenter.codeField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).distinctUntilChanged().map(ResetPasswordCodeStateObject.Event.onChangeCode),
                presenter.validButton.rx.tap.asSignal().map { ResetPasswordCodeStateObject.Event.onTriggerVerify },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let verifyCode: Feedback = react(query: { $0.verifyCodeQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.verifyCode }.unwrap()
                .map(ResetPasswordCodeStateObject.Event.onVerifySuccess)
                .asSignal(onErrorReturnJust: ResetPasswordCodeStateObject.Event.onVerifyError)
        })
        
        let getVerifyCode: Feedback = react(query: { $0.getVerifyCodeQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            return ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.getVerifyCode }.unwrap()
                .map(ResetPasswordCodeStateObject.Event.onGetVerifyCodeSuccess)
                .asSignal(onErrorReturnJust: ResetPasswordCodeStateObject.Event.onGetVerifyCodeError)
        })
        
        let states = store.states
//            .debug("ResetPasswordCodeState")
        
        Signal.merge(
            uiFeedback(states),
            verifyCode(states),
            getVerifyCode(states)
            )
            .debug("ResetPasswordCodeState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension ResetPasswordCodeStateObject {
    
    fileprivate var isResetPasswordEnabled: Bool {
        return isCodeAvaliable && !triggerVerifyCodeQuery
    }
    
    fileprivate var detail: String {
        return phoneNumber != nil ? "已发送 6 位数验证码" : " "
    }
}

