//
//  ResetPasswordPhoneViewController.swift
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

final class ResetPasswordPhonePresenter: NSObject {
    @IBOutlet weak var phoneField: TextField!
    @IBOutlet weak var nextButton: RaisedButton!
    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareNavigationItem()
        prepareUsernameField()
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "忘记密码"
        navigationItem.titleLabel.textColor = .primaryText
    }
    
    fileprivate func prepareUsernameField() {
        phoneField.isClearIconButtonEnabled = true
        phoneField.placeholderActiveColor = .primary
        phoneField.dividerActiveColor = .primary
        phoneField.autocapitalizationType = .none
        //        _ = phoneField.becomeFirstResponder()
    }
}

final class ResetPasswordPhoneViewController: BaseViewController {
    
    @IBOutlet fileprivate var presenter: ResetPasswordPhonePresenter!
    fileprivate typealias Feedback = (Driver<ResetPasswordPhoneStateObject>) -> Signal<ResetPasswordPhoneStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? ResetPasswordPhoneStateStore() else { return }
        
        presenter.setup(navigationItem: navigationItem)
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.resetPasswordParam?.phoneNumber ?? "" }.asObservable().take(1).bind(to: presenter.phoneField.rx.text),
                state.map { $0.isPhoneNumberValid }.distinctUntilChanged().drive(presenter.nextButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.debounce(0.1).drive(presenter.phoneField.rx.detail),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.phoneField.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.phoneField.rx.resignFirstResponder()),
                ]
            let events: [Signal<ResetPasswordPhoneStateObject.Event>] = [
                presenter.phoneField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).distinctUntilChanged().map(ResetPasswordPhoneStateObject.Event.onChangePhoneNumber),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let phoneNumberAvailable: Feedback = react(query: { $0.phoneNumberAvailableQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.searchUserByPhoneNumber?.username }
                .asSignal(onErrorJustReturn: nil)
                .map(ResetPasswordPhoneStateObject.Event.onPhoneNumberAvailableResponse)
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            phoneNumberAvailable(states)
            )
            .debug("ResetPasswordPhoneState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
    }
}

extension ResetPasswordPhoneStateObject {
    
    var detail: String {
        if resetPasswordParam?.phoneNumber.isEmpty == true {
            return " "
        }
        if !shouldValidPhone {
            return "请输入 11 位手机号"
        }
        if triggerValidPhoneQuery {
            return "正在验证..."
        }
        if !isPhoneNumberValid {
            return "手机号未注册"
        }
        return " "
    }
}


