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
import RealmSwift

final class ResetPasswordCodePresenter: NSObject {
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

final class ResetPasswordCodeViewController: BaseViewController, IsStateViewController {
    
    typealias State = ResetPasswordCodeStateObject
    typealias Event = State.Event
    
    @IBOutlet fileprivate var presenter: ResetPasswordCodePresenter!
    
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
            verifyCode: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.verifyCode }.forceUnwrap()
        })
            .drive()
            .disposed(by: disposeBag)
    }
    
    var uiFeedback: State.DriverFeedback {
        return bind(self) { (me, state) in
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
    }
}

extension ResetPasswordCodeStateObject {
    
    fileprivate var isResetPasswordEnabled: Bool {
        return isCodeValid && verifyCodeQueryState?.trigger == false
    }
    
    fileprivate var detail: String {
        return getVerifyCodeQueryState?.success != nil ? "已发送 6 位数验证码" : " "
    }
}

