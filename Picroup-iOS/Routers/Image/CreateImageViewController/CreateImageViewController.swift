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
import RealmSwift

final class CreateImageViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias State = CreateImageStateObject
    typealias Event = State.Event
    
    typealias Dependency = [MediumItem]
    var dependency: Dependency?
    
    @IBOutlet fileprivate var presenter: CreateImagePresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setup(navigationItem: navigationItem, mediaItemsCount: dependency?.count ?? 0)
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {

        guard let mediaItems = dependency,
            let realm = try? Realm(),
            let state = try? State.create(mediaItems: mediaItems)(realm) else { return }
        
        state.system(
            uiFeedback: uiFeedback,
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            saveMedium: { userId,mediaItem,tags  in
                switch mediaItem {
                case .image(let imageKey):
                    return MediumService.saveMedium(client: ApolloClient.shared, userId: userId, imageKey: imageKey, tags: tags)
                case .video(let thumbnailImageKey, let videoFileURL):
                    return  MediumService.saveVideo(client: ApolloClient.shared, userId: userId, thumbnailImageKey: thumbnailImageKey, videoFileURL: videoFileURL, tags: tags)
                }
        })
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    var uiFeedback: State.DriverFeedback {
        return bind(self) { (me, state) in
            let subscriptions = [
                state.map { $0.saveMediumStates() }.drive(me.presenter.collectionView.rx.items(cellIdentifier: "BasicImageCell", cellType: BasicImageCell.self)) { index, item, cell in
                    let image = ImageCache.default.retrieveImage(forKey: item._id)
                    cell.imageView.image = image
                },
                state.map { $0.tagStates() }.drive(me.presenter.tagsCollectionView.rx.items(cellIdentifier: "TagCollectionViewCell", cellType: TagCollectionViewCell.self)) { index, tagState, cell in
                    cell.tagLabel.text = tagState.tag
                    cell.setSelected(tagState.isSelected)
                },
                state.map { $0.saveImagesQueryState?.shouldQuery ?? false }.distinctUntilChanged().drive(me.presenter.saveButton.rx.isEnabledWithBackgroundColor(.secondary)),
                state.map { $0.saveImagesQueryState?.completed ?? 0 }.drive(me.presenter.progressView.rx.progress),
                ]
            let events: [Signal<Event>] = [
                me.presenter.tagsCollectionView.rx.modelSelected(TagStateObject.self).asSignal().map { .onToggleTag($0.tag) },
                me.presenter.didCommitTag.asSignal().map(Event.onAddTag),
                me.presenter.saveButton.rx.tap.asSignal().map { .onTriggerSaveMedium },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

extension CreateImageStateObject {
    func saveMediumStates() -> [SaveMediumStateObject] {
        return saveImagesQueryState?.saveMediumStates.toArray() ?? []
    }
    
    func tagStates() -> [TagStateObject] {
        return tagsState?.tagStates.toArray() ?? []
    }
}
