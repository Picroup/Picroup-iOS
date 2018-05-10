//
//  CreateImageViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

class CreateImageViewController: UIViewController {
    
    typealias Dependency = (image: UIImage, client: ApolloClient)
    var dependency: Dependency?
    var savedMedium: Signal<CreateImageState.SaveImageMedium> {
        return _savedMedium.asSignal()
    }
    
    fileprivate typealias Feedback = DriverFeedback<CreateImageState>
    @IBOutlet fileprivate var presenter: CreateImagePresenter!
    fileprivate let _savedMedium = PublishRelay<CreateImageState.SaveImageMedium>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let dependency = dependency else { return }
        
        let injectDependncy = self.injectDependncy(store: store)
        let syncState = self.syncState(savedMedium: _savedMedium)
        let uiFeedback = self.uiFeedback
        let saveMedium = Feedback.saveMedium(client: dependency.client)
        
        let initialState = CreateImageState.empty(
            pickedImage: dependency.image
        )
        
        let reduce = logger(identifier: "CreateImageState")(CreateImageState.reduce)
        
        Driver<Any>.system(
            initialState: initialState,
            reduce: reduce,
            feedback:
                injectDependncy,
                syncState,
                uiFeedback,
                saveMedium
            )
            .drive()
            .disposed(by: disposeBag)
    
    }
    
}

extension CreateImageViewController {
    
    fileprivate func injectDependncy(store: Store) -> Feedback.Raw {
        return { _ in
            store.state.map { $0.currentUser?.toUser() }.asSignal(onErrorJustReturn: nil).map { .onUpdateCurrentUser($0) }
        }
    }
    
    fileprivate func syncState(savedMedium: PublishRelay<CreateImageState.SaveImageMedium>) -> Feedback.Raw {
        return  bind { (state) in
            let subscriptions = [
                state.map { $0.savedMedium }.asSignal(onErrorJustReturn: nil).unwrap().emit(to: savedMedium)
            ]
            let events = [
                Signal<CreateImageState.Event>.never()
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
    
    fileprivate var uiFeedback: Feedback.Raw {
       return  bind(self) { (me, state) in
            let eventsTrigger = PublishRelay<CreateImageState.Event>()
            let subscriptions = [
                state.map { $0.next.pickedImage }.drive(me.presenter.imageView.rx.image),
                state.map { $0.progress?.completed ?? 0 }.distinctUntilChanged().drive(me.presenter.progressView.rx.progress),
                state.map { $0.shouldSaveImage }.distinctUntilChanged().drive(me.presenter.saveButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.triggerCancel }.distinctUnwrap().drive(me.rx.dismiss(animated: true)),
                state.map { $0.savedMedium }.distinctUnwrap().map { _ in "已分享" }.drive(me.snackbarController!.rx.snackbarText),
                state.map { $0.savedMedium }.distinctUnwrap().mapToVoid().delay(3.3).drive(me.rx.dismiss(animated: true)),
                ]
            let events = [
                eventsTrigger.asSignal(),
                me.presenter.cancelButton.rx.tap.asSignal().map { CreateImageState.Event.triggerCancel },
                me.presenter.saveButton.rx.tap.asSignal().map { CreateImageState.Event.triggerSave }
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}
