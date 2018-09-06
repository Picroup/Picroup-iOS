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
import RealmSwift

final class RegisterPasswordPresenter: NSObject {
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var nextButton: RaisedButton!
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

final class RegisterPasswordViewController: BaseViewController, IsStateViewController {
    
    typealias State = RegisterPasswordStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate var presenter: RegisterPasswordPresenter!
    
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
            queryValidPassword: ValidationService.queryValidPassword())
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.registerParamState?.password ?? "" }.asObservable().take(1).bind(to: presenter.passwordField.rx.text),
                state.map { $0.isPasswordValid }.distinctUntilChanged().drive(presenter.nextButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.drive(presenter.passwordField.rx.detail),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.passwordField.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.passwordField.rx.resignFirstResponder()),
                ]
            let events: [Signal<Event>] = [
                presenter.passwordField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).distinctUntilChanged().map(Event.onChangePassword),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension RegisterPasswordStateObject {
    
    var detail: String {
        if registerParamState?.password.isEmpty == true {
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
