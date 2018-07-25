//
//  RegisterPasswordViewController.swift
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

final class RegisterPasswordPresenter: NSObject {
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var nextButton: RaisedButton!
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

final class RegisterPasswordViewController: UIViewController {
    
    @IBOutlet fileprivate var presenter: RegisterPasswordPresenter!
    fileprivate typealias Feedback = (Driver<RegisterPasswordStateObject>) -> Signal<RegisterPasswordStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? RegisterPasswordStateStore() else { return }

        presenter.setup(navigationItem: navigationItem)

        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.registerParam?.password ?? "" }.asObservable().take(1).bind(to: presenter.passwordField.rx.text),
                state.map { $0.isPasswordValid }.distinctUntilChanged().drive(presenter.nextButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.drive(presenter.passwordField.rx.detail),
                ]
            let events: [Signal<RegisterPasswordStateObject.Event>] = [
                presenter.passwordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).map(RegisterPasswordStateObject.Event.onChangePassword),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }

        let states = store.states

        Signal.merge(
            uiFeedback(states)
            )
            .debug("RegisterPasswordState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension RegisterPasswordStateObject {
    
    var detail: String {
        if registerParam?.password.isEmpty == true {
            return " "
        }
        if !isPasswordValid {
            return "大小写字母加数字，至少需要 8 个字"
        }
        return " "
    }
}
