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

class CreateImageViewController: ShowNavigationBarViewController {
    
    typealias Dependency = [String]
    var dependency: Dependency?
    
    fileprivate typealias Feedback = (Driver<CreateImageStateObject>) -> Signal<CreateImageStateObject.Event>
    @IBOutlet fileprivate var presenter: CreateImagePresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {

        guard
            let imageKeys = dependency,
            let store = try? CreateImageStateStore(imageKeys: imageKeys)
            else {
                return
        }
        
        navigationItem.titleLabel.text = "共 \(imageKeys.count) 张" 
        navigationItem.titleLabel.textColor = .primaryText

        let uiFeedback: Feedback =  bind(self) { (me, state) in
            let subscriptions = [
                store.saveMediumStates().drive(me.presenter.collectionView.rx.items(cellIdentifier: "RankMediumCell", cellType: RankMediumCell.self)) { index, item, cell in
                    let image = ImageCache.default.retrieveImageInMemoryCache(forKey: item._id)
                    cell.imageView.image = image
                    cell.progressView.progress = item.progress?.completed ?? 0
                },
//                state.map { $0.shouldSaveMedium }.distinctUntilChanged().drive(me.presenter.saveButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.completed }.drive(me.presenter.progressView.rx.progress),
                ]
            let events: [Signal<CreateImageStateObject.Event>] = [
//                me.presenter.saveButton.rx.tap.asSignal().map { CreateImageStateObject.Event.onTriggerSaveMedium }
                .never()
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let saveMediums: Feedback = react(query: { $0.saveQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { (query) in
            let (userId, imageKeys) = query
            let queries: [Signal<CreateImageStateObject.Event>] = imageKeys.enumerated().map { index, imageKey in
               let image = ImageCache.default.retrieveImageInMemoryCache(forKey: imageKey)!
                return MediumService.saveMedium(client: ApolloClient.shared, userId: userId, pickedImage: image)
                    .map { result in
                        switch result {
                        case .progress(let progress):
                            return CreateImageStateObject.Event.onProgress(progress, index)
                        case .completed(let medium):
                            return CreateImageStateObject.Event.onSavedMediumSuccess(medium, index)
                        }
                    }.asSignal(onErrorReturnJust: { .onSavedMediumError($0, index) })
            }
            return Signal.concat(queries)
        })
        
        let states = store.states
//            .debug("CreateImageState")
        
        Signal.merge(
            uiFeedback(states),
            saveMediums(states)
            )
            .debug("CreateImageState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
    
        presenter.collectionView.rx.setDelegate(presenter).disposed(by: disposeBag)
    }
    
}

