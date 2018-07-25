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

final class RegisterPhonePresenter: NSObject {
    @IBOutlet weak var phoneField: TextField!
    @IBOutlet weak var nextButton: RaisedButton!
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
        phoneField.isClearIconButtonEnabled = true
        phoneField.placeholderActiveColor = .primary
        phoneField.dividerActiveColor = .primary
        phoneField.autocapitalizationType = .none
//        _ = phoneField.becomeFirstResponder()
    }
}

final class RegisterPhoneViewController: UIViewController {
    
    @IBOutlet fileprivate var presenter: RegisterPhonePresenter!
    fileprivate typealias Feedback = (Driver<RegisterPhoneStateObject>) -> Signal<RegisterPhoneStateObject.Event>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let store = try? RegisterPhoneStateStore() else { return }

        presenter.setup(navigationItem: navigationItem)

        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.registerParam?.phoneNumber ?? "" }.asObservable().take(1).bind(to: presenter.phoneField.rx.text),
                state.map { $0.isPhoneNumberValid }.distinctUntilChanged().drive(presenter.nextButton.rx.isEnabledWithBackgroundColor(.secondary)),
                ]
            let events: [Signal<RegisterPhoneStateObject.Event>] = [
                presenter.phoneField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).map(RegisterPhoneStateObject.Event.onChangePhoneNumber),
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }


        let states = store.states

        Signal.merge(
            uiFeedback(states)
            )
            .debug("RegisterPhoneState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
    }
}
