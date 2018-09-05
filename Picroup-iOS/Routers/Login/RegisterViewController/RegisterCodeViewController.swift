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
import RealmSwift

final class RegisterCodePresenter: NSObject {
    @IBOutlet weak var codeField: TextField!
    @IBOutlet weak var validButton: RaisedButton!
    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareUsernameField()
    }
    
    fileprivate func prepareUsernameField() {
        codeField.isClearIconButtonEnabled = true
        codeField.placeholderActiveColor = .primary
        codeField.dividerActiveColor = .primary
        codeField.autocapitalizationType = .none
//        _ = codeField.becomeFirstResponder()
    }
}

final class RegisterCodeViewController: BaseViewController, IsStateViewController {
    
    typealias State = RegisterCodeStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate var presenter: RegisterCodePresenter!
    
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
            getVerifyCode: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.getVerifyCode }.forceUnwrap()
        },
            queryValidCode: ValidationService.queryValidCode(),
            register: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.register.fragments.userDetailFragment }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                state.map { $0.isRegisterEnabled }.distinctUntilChanged().drive(presenter.validButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.detail }.drive(presenter.codeField.rx.detail),
                presenter.validButton.rx.tap.asSignal().emit(to: presenter.codeField.rx.resignFirstResponder()),
                me.rx.viewDidAppear.asSignal().mapToVoid().emit(to: presenter.codeField.rx.becomeFirstResponder()),
                me.rx.viewWillDisappear.asSignal().mapToVoid().emit(to: presenter.codeField.rx.resignFirstResponder()),
                ]
            let events: [Signal<Event>] = [
                .just(.onTriggerGetVerifyCode),
                presenter.codeField.rx.text.orEmpty.asSignalOnErrorRecoverEmpty().debounce(0.5).distinctUntilChanged().map(Event.onChangeCode),
                presenter.validButton.rx.tap.asSignal().map { .onTriggerRegister },
                ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension RegisterCodeStateObject {
    
    fileprivate var isRegisterEnabled: Bool {
        return isCodeValid && registerQueryState?.trigger == false
    }
    
    fileprivate var detail: String {
        return getVerifyCodeQueryState?.success != nil ? "已发送 6 位数验证码" : " "
    }
}
