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
import RealmSwift

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
//        _ = usernameField.becomeFirstResponder()
    }
}

final class RegisterUsernameViewController: BaseViewController, IsStateViewController {
    
    typealias State = RegisterUsernameStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate var presenter: RegisterUsernamePresenter!
    
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
            queryIsRegisterUsernameAvailable: ValidationService.queryIsRegisterUsernameAvailable(queryUsernameAvailable: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.searchUser }
            }))
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.registerParamState?.username ?? "" }.asObservable().take(1).bind(to: presenter.usernameField.rx.text),
                state.map { $0.isUsernameAvaliable }.distinctUntilChanged().drive(presenter.nextButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.debounce(0.1).drive(presenter.usernameField.rx.detail),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.usernameField.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.usernameField.rx.resignFirstResponder()),
                ]
            let events: [Signal<Event>] = [
                presenter.usernameField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).distinctUntilChanged().map(Event.onChangeUsername),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension RegisterUsernameStateObject {
    
    var detail: String {
        if registerParamState?.username.isEmpty == true {
            return " "
        }
        if registerUsernameAvailableQueryState?.trigger == true {
            return "正在验证..."
        }
        if let error = registerUsernameAvailableQueryState?.error {
            return error
        }
        return " "
    }
}

extension Reactive where Base: TextField {
    var detail: Binder<String?> {
        return Binder(base) { textField, detail in
            textField.detail = detail
        }
    }
}
