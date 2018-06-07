//
//  RegisterUsernameViewController.swift
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

final class RegisterUsernamePresenter: NSObject {
    @IBOutlet weak var usernameField: TextField!
    @IBOutlet weak var nextButton: RaisedButton!
    weak var navigationItem: UINavigationItem!

    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareNavigationItem()
        prepareUsernameField()
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "注册"
        navigationItem.titleLabel.textColor = .primaryText
    }

    fileprivate func prepareUsernameField() {
        usernameField.isClearIconButtonEnabled = true
        usernameField.placeholderActiveColor = .primary
        usernameField.dividerActiveColor = .primary
        usernameField.autocapitalizationType = .none
        _ = usernameField.becomeFirstResponder()
    }
}

final class RegisterUsernameViewController: UIViewController {
    
    @IBOutlet fileprivate var presenter: RegisterUsernamePresenter!
    fileprivate typealias Feedback = (Driver<RegisterUsernameStateObject>) -> Signal<RegisterUsernameStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? RegisterUsernameStateStore() else { return }
        
        presenter.setup(navigationItem: navigationItem)
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.registerParam?.username ?? "" }.asObservable().take(1).bind(to: presenter.usernameField.rx.text),
                state.map { $0.isUsernameAvaliable }.distinctUntilChanged().drive(presenter.nextButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.debounce(0.5).drive(presenter.usernameField.rx.detail),
                ]
            let events: [Signal<RegisterUsernameStateObject.Event>] = [
                presenter.usernameField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).map(RegisterUsernameStateObject.Event.onChangeUsername),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let usernameAvailable: Feedback = react(query: { $0.usernameAvailableQuery }) { query in
            return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.searchUser?.username }
                .asSignal(onErrorJustReturn: nil)
                .map(RegisterUsernameStateObject.Event.onUserAvailableResponse)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            usernameAvailable(states)
            )
            .debug("RegisterUsernameState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    }
}

extension RegisterUsernameStateObject {
    
    var detail: String {
        if !shouldValidUsername {
            return "字母加数字，至少需要 4 个字"
        }
        if triggerValidUsernameQuery {
            return "正在验证..."
        }
        if !isUsernameAvaliable {
            return "用户名已被注册"
        }
        return "用户名可用"
    }
}

extension Reactive where Base: TextField {
    var detail: Binder<String?> {
        return Binder(base) { textField, detail in
            textField.detail = detail
        }
    }
}
