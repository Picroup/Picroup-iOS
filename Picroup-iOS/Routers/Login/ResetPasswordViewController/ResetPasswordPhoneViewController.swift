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
import RealmSwift

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

final class ResetPasswordPhoneViewController: BaseViewController, IsStateViewController {
    
    typealias State = ResetPasswordPhoneStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate var presenter: ResetPasswordPhonePresenter!
    
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
            queryIsResetPhoneNumberAvailable: ValidationService.queryIsResetPhoneNumberAvailable(queryPhoneNumberAvailable: { query in
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
                state.map { $0.resetPasswordStateParam?.phoneNumber ?? "" }.asObservable().take(1).bind(to: presenter.phoneField.rx.text),
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
    }
}

extension ResetPasswordPhoneStateObject {
    
    var detail: String {
        if resetPasswordStateParam?.phoneNumber.isEmpty == true {
            return " "
        }
        if resetPhoneAvailableQueryState?.trigger == true {
            return "正在验证..."
        }
        if let error = resetPhoneAvailableQueryState?.error {
            return error
        }
        return " "
    }
}


