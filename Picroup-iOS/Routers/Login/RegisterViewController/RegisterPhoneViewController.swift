//
//  RegisterPhoneViewController.swift
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

final class RegisterPhonePresenter: NSObject {
    @IBOutlet weak var phoneField: TextField!
    @IBOutlet weak var nextButton: RaisedButton!
    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareUsernameField()
    }
    
    fileprivate func prepareUsernameField() {
        phoneField.isClearIconButtonEnabled = true
        phoneField.placeholderActiveColor = .primary
        phoneField.dividerActiveColor = .primary
        phoneField.autocapitalizationType = .none
//        _ = phoneField.becomeFirstResponder()
    }
}

final class RegisterPhoneViewController: BaseViewController, IsStateViewController {
    
    typealias State = RegisterPhoneStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate var presenter: RegisterPhonePresenter!
    
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
            queryIsRegisterPhoneNumberAvailable: ValidationService.queryIsRegisterPhoneNumberAvailable(queryPhoneNumberAvailable: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.searchUserByPhoneNumber }
            }))
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    var uiFeedback: State.DriverFeedback {
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.registerParamState?.phoneNumber ?? "" }.asObservable().take(1).bind(to: presenter.phoneField.rx.text),
                state.map { $0.isPhoneNumberValid }.distinctUntilChanged().drive(presenter.nextButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.debounce(0.1).drive(presenter.phoneField.rx.detail),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.phoneField.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.phoneField.rx.resignFirstResponder()),
                ]
            let events: [Signal<RegisterPhoneStateObject.Event>] = [
                presenter.phoneField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).distinctUntilChanged().map(RegisterPhoneStateObject.Event.onChangePhoneNumber),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension RegisterPhoneStateObject {
    
    var detail: String {
        if registerParamState?.phoneNumber.isEmpty == true {
            return " "
        }
        if registerPhoneAvailableQueryState?.trigger == true {
            return "正在验证..."
        }
        if let error = registerPhoneAvailableQueryState?.error {
            return error
        }
        return " "
    }
}
