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
import Kingfisher

class CreateImageViewController: UIViewController {
    
    typealias Dependency = String
    var dependency: Dependency?
    
    fileprivate typealias Feedback = (Driver<CreateImageStateObject>) -> Signal<CreateImageStateObject.Event>
    @IBOutlet fileprivate var presenter: CreateImagePresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {

        guard
            let imageKey = dependency,
            let store = try? CreateImageStateStore(imageKey: imageKey),
            let image = ImageCache.default.retrieveImageInMemoryCache(forKey: imageKey)
            else {
                return
        }
        
        let uiFeedback: Feedback =  bind(self) { (me, state) in
            let subscriptions = [
                Driver.just(image).drive(me.presenter.imageView.rx.image),
                state.map { $0.progress?.completed ?? 0 }.distinctUntilChanged().drive(me.presenter.progressView.rx.progress),
                state.map { $0.shouldSaveMedium }.distinctUntilChanged().drive(me.presenter.saveButton.rx.isEnabledWithBackgroundColor(.secondary)),
                me.presenter.cancelButton.rx.tap.asSignal().emit(to: me.rx.dismiss(animated: true)),
                state.map { $0.savedMedium }.distinctUnwrap().map { _ in "已分享" }.drive(me.snackbarController!.rx.snackbarText),
                state.map { $0.savedMedium }.distinctUnwrap().mapToVoid().delay(2.3).drive(me.rx.dismiss(animated: true)),
                ]
            let events: [Signal<CreateImageStateObject.Event>] = [
                me.presenter.saveButton.rx.tap.asSignal().map { CreateImageStateObject.Event.onTriggerSaveMedium }
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let saveMedium: Feedback = react(query: { $0.saveQuery }) { (query) in
            return MediumService.saveMedium(client: ApolloClient.shared, userId: query.userId, pickedImage: image)
                .map { result in
                    switch result {
                    case .progress(let progress):
                        return CreateImageStateObject.Event.onProgress(progress)
                    case .completed(let medium):
                        return CreateImageStateObject.Event.onSavedMediumSuccess(medium)
                    }
                }.asSignal(onErrorReturnJust: CreateImageStateObject.Event.onSavedMediumError)
        }
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            saveMedium(states)
            )
            .debug("CreateImageStateObject", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    
    }
    
}

