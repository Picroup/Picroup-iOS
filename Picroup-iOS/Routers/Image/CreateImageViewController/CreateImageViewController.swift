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
    
    typealias Dependency = [MediaItem]
    var dependency: Dependency?
    
    fileprivate typealias Feedback = (Driver<CreateImageStateObject>) -> Signal<CreateImageStateObject.Event>
    @IBOutlet fileprivate var presenter: CreateImagePresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {

        guard
            let mediaItems = dependency,
            let store = try? CreateImageStateStore(mediaItems: mediaItems)
            else {
                return
        }
        
        navigationItem.titleLabel.text = "共 \(mediaItems.count) 个"
        navigationItem.titleLabel.textColor = .primaryText

        let uiFeedback: Feedback =  bind(self) { (me, state) in
            let subscriptions = [
                store.saveMediumStates().drive(me.presenter.collectionView.rx.items(cellIdentifier: "RankMediumCell", cellType: RankMediumCell.self)) { index, item, cell in
                    let image = ImageCache.default.retrieveImage(forKey: item._id)
                    cell.imageView.image = image
                    cell.progressView.isHidden = true
                },
                store.tagStates().drive(me.presenter.tagsCollectionView.rx.items(cellIdentifier: "TagCollectionViewCell", cellType: TagCollectionViewCell.self)) { index, tagState, cell in
                    cell.tagLabel.text = tagState.tag
                    cell.setSelected(tagState.isSelected)
                },
                state.map { $0.shouldSaveMedium }.distinctUntilChanged().drive(me.presenter.saveButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.completed }.drive(me.presenter.progressView.rx.progress),
                ]
            let events: [Signal<CreateImageStateObject.Event>] = [
                me.presenter.tagsCollectionView.rx.modelSelected(TagStateObject.self).asSignal().map { .onToggleTag($0.tag) },
                me.presenter.didCommitTag.asSignal().map(CreateImageStateObject.Event.onAddTag),
                me.presenter.saveButton.rx.tap.asSignal().map { CreateImageStateObject.Event.onTriggerSaveMedium },
//                .never()
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let saveMediums: Feedback = react(query: { $0.saveQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { (query) in
            let (userId, mediaItems, tags) = query
            let queries: [Signal<CreateImageStateObject.Event>] = mediaItems.enumerated().map { index, mediaItem in
                let saveMedium: Observable<MediumService.SaveMediumResult>
                switch mediaItem {
                case .image(let imageKey):
                    saveMedium = MediumService.saveMedium(client: ApolloClient.shared, userId: userId, imageKey: imageKey, tags: tags)
                case .video(let thumbnailImageKey, let videoFileURL):
                    saveMedium = MediumService.saveVideo(client: ApolloClient.shared, userId: userId, thumbnailImageKey: thumbnailImageKey, videoFileURL: videoFileURL, tags: tags)
                }
                return saveMedium.map { result in
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
        
    }
}

