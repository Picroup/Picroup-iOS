//
//  UpdateMediumTagsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo
import Kingfisher

final class UpdateMediumTagsViewController: ShowNavigationBarViewController {
    
    typealias Dependency = String
    var dependency: Dependency?
    
    fileprivate typealias Feedback = (Driver<UpdateMediumTagsStateObject>) -> Signal<UpdateMediumTagsStateObject.Event>
    @IBOutlet fileprivate var presenter: UpdateMediumTagsPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard
            let mediumId = dependency,
            let store = try? UpdateMediumTagsStateStore(mediumId: mediumId)
            else { return }
        
        let uiFeedback: Feedback =  bind(self) { (me, state) in
            let subscriptions = [
                store.tagStates().drive(me.presenter.tagsCollectionView.rx.items(cellIdentifier: "TagCollectionViewCell", cellType: TagCollectionViewCell.self)) { index, tagState, cell in
                    cell.tagLabel.text = tagState.tag
                    cell.setSelected(tagState.isSelected)
                },
                ]
            let events: [Signal<UpdateMediumTagsStateObject.Event>] = [
                me.presenter.tagsCollectionView.rx.modelSelected(TagStateObject.self).asSignal().map { .onToggleTag($0.tag) },
                me.presenter.didCommitTag.asSignal().map(UpdateMediumTagsStateObject.Event.onAddTag),
                //                .never()
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let addTag: Feedback = react(query: { $0.addTagQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { (query) in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.medium?.addTag.fragments.mediumFragment }.unwrap()
                .map(UpdateMediumTagsStateObject.Event.onAddTagSuccess)
                .asSignal(onErrorReturnJust: { .onAddTagError($0, query.tag) })
        })
        
        let remeveTag: Feedback = react(query: { $0.removeTagQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { (query) in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.medium?.removeTag.fragments.mediumFragment }.unwrap()
                .map(UpdateMediumTagsStateObject.Event.onRemoveTagSuccess)
                .asSignal(onErrorReturnJust: { .onRemoveTagError($0, query.tag) })
        })
        
        let states = store.states
        //            .debug("CreateImageState")
        
        Signal.merge(
            uiFeedback(states),
            addTag(states),
            remeveTag(states)
            )
            .debug("UpdateMediumTagsState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        //        presenter.collectionView.rx.setDelegate(presenter).disposed(by: disposeBag)
        
    }
}


