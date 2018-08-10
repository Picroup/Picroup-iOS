//
//  ImageDetailViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/16.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import Apollo
import Kingfisher

private func mapMoreButtonTapToEvent(sender: UICollectionView) -> (ImageDetailStateObject) -> Signal<ImageDetailStateObject.Event> {
    return { state in
        
        guard state.session?.isLogin == true else {
            return .just(.onTriggerLogin)
        }
        guard let cell = sender.cellForItem(at: IndexPath(item: 0, section: 0)) as? HasMoreButton else { return .empty() }
        let isMyMedium = state.medium?.userId == state.session?.currentUserId
        let actions: [String]
        switch (isMyMedium, state.session?.currentUser?.reputation.value) {
        case (true, _):
            actions = ["更新标签", "删除"]
        case (false, let reputation?) where reputation > 100:
            actions = ["更新标签", "举报", "减少类似内容"]
        case (false, _):
            actions = ["举报", "减少类似内容"]
        }
        return DefaultWireframe.shared
            .promptFor(sender: cell.moreButton, cancelAction: "取消", actions: actions)
            .asSignalOnErrorRecoverEmpty()
            .flatMap { action in
                switch action {
                case "更新标签":      return .just(.onTriggerUpdateMediaTags)
                case "举报":         return .just(.onTriggerMediumFeedback)
                case "减少类似内容":  return .just(.onTriggerBlockMedium)
                case "删除":         return comfirmDelete()
                default:            return .empty()
                }
        }
    }
}

private func comfirmDelete() -> Signal<ImageDetailStateObject.Event> {
    return DefaultWireframe.shared
        .promptFor(message: "确定要删除它吗？", preferredStyle: .alert, sender: nil, cancelAction: "取消", actions: ["删除"])
        .asSignalOnErrorRecoverEmpty()
        .flatMap { action in
            switch action {
            case "删除":     return .just(.onTriggerDeleteMedium)
            default:        return .empty()
            }
    }
}

fileprivate typealias Section = MediumDetailPresenter.Section
fileprivate typealias CellStyle = MediumDetailPresenter.CellStyle

class ImageDetailViewController: ShowNavigationBarViewController {
    
    typealias Dependency = String
    var dependency: Dependency!
    
    fileprivate typealias Feedback = (Driver<ImageDetailStateObject>) -> Signal<ImageDetailStateObject.Event>
    @IBOutlet var presenter: ImageDetailPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard
            let mediumId = dependency,
            let store = try? ImageDetailStateStore(mediumId: mediumId)
            else {
                return
        }
        
        appStateService?.events.accept(.onViewMedium(mediumId))
        
        let _events = PublishRelay<ImageDetailStateObject.Event>()
        let _moreButtonTap = PublishRelay<Void>()
        
        // I known this is ugly but it enabled the transition animations
        let sections = Observable.combineLatest(store.sections, store.states.asObservable()) { $1.isMediumDeleted ? [] : $0 }
        
        sections
            .bind(to: presenter.mediumDetailPresenter.items(events: _events, moreButtonTap: _moreButtonTap))
            .disposed(by: disposeBag)
        
        let uiFeedback: Feedback = bind(self) { (me, state) in
            let presenter = me.presenter!

            let subscriptions = [
                sections.map { $0.isEmpty }.subscribe(onNext: { presenter.collectionView.backgroundView = $0 ? presenter.deleteAlertView : nil }),
                presenter.backgroundButton.rx.tap.subscribe(onNext: { _events.accept(.onTriggerPop) }),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                ]
            let events: [Signal<ImageDetailStateObject.Event>] = [
                .just(.onTriggerReloadData),
                _events.asSignal(),
                _moreButtonTap.asSignal().withLatestFrom(state).flatMapLatest(mapMoreButtonTapToEvent(sender: presenter.collectionView)),
                state.flatMapLatest {
                    $0.shouldQueryMoreRecommendMedia
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreData },
                me.presenter.collectionView.rx.modelSelected(MediumDetailPresenter.CellStyle.self).asSignal()
                    .flatMapLatest { cellStyle -> Signal<ImageDetailStateObject.Event> in
                        switch cellStyle {
                        case .recommendMedium(let medium):
                            return .just(.onTriggerShowImage(medium._id))
                        case .imageTag(let tag):
                            return .just(.onTriggerShowTagMedia(tag))
                        default:
                            return .empty()
                        }
                },
                presenter.deleteAlertView.rx.tapGesture().when(.recognized).asSignalOnErrorRecoverEmpty().map { _ in .onTriggerPop },
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        let queryMedium: Feedback = react(query: { $0.mediumQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                .map { $0?.data?.medium }
                .map(ImageDetailStateObject.Event.onGetData(isReload: query.cursor == nil))
                .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onGetError)
                .delay(0.4)
        })
        
        let starMedium: Feedback = react(query: { $0.starMediumQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.starMedium }.unwrap()
                .map(ImageDetailStateObject.Event.onStarMediumSuccess)
                .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onStarMediumError)
        })
        
        let deleteMedium: Feedback = react(query: { $0.deleteMediumQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.deleteMedium }.unwrap()
                .map(ImageDetailStateObject.Event.onDeleteMediumSuccess)
                .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onDeleteMediumError)
        })
        
        let blockMedium: Feedback = react(query: { $0.blockUserQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            ApolloClient.shared.rx.perform(mutation: query)
                .map { $0?.data?.blockMedium.fragments.userFragment }.unwrap()
                .map(ImageDetailStateObject.Event.onBlockMediumSuccess)
                .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onBlockMediumError)
        })
        
        let shareMedium: Feedback = react(query: { $0.shareMediumQuery }, effects: composeEffects(shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  }) { query in
            let (username, mediumItem) = query
            switch mediumItem {
            case .image(let cacheKey):
                let image = ImageCache.default.retrieveImage(forKey: cacheKey)!
                return WatermarkService.addImageWatermark(image: image, username: username)
                    .observeOn(MainScheduler.instance)
                    .do(onSuccess: { [weak self] item in
                        let vc = UIActivityViewController(activityItems: [item], applicationActivities: nil)
                        self?.present(vc, animated: true, completion: nil)
                    })
                    .map { _ in .onShareMediumSuccess }
                    .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onShareMediumError)

            case .video(thumbnailImageKey: _, videoFileURL: let url):
                let videoURL = Cacher.fileURL(for: url.cacheKey)!
                return WatermarkService.addVideoWatermark(videoURL: videoURL, username: username)
                    .observeOn(MainScheduler.instance)
                    .do(onSuccess: { [weak self] item in
                        let vc = UIActivityViewController(activityItems: [item], applicationActivities: nil)
                        self?.present(vc, animated: true, completion: nil)
                    })
                    .map { _ in .onShareMediumSuccess }
                    .asSignal(onErrorReturnJust: ImageDetailStateObject.Event.onShareMediumError)
            }
        })
        
        let states = store.states
        
        Signal.merge(
            uiFeedback(states),
            queryMedium(states),
            starMedium(states),
            deleteMedium(states),
            blockMedium(states),
            shareMedium(states)
            )
            .debug("ImageDetailState.Event", trimOutput: true)
            .emit(onNext: store.on)
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter.mediumDetailPresenter).disposed(by: disposeBag)
    }
}

extension ImageDetailStateStore {
    
    fileprivate var sections: Observable<[Section]> {
        return mediumWithRecommendMedia().map { data in
            let (medium, items) = data
            var result = [Section]()
            guard !medium.isInvalidated else { return result }
            result.append(Section(
                model: .imageDetail,
                items: [CellStyle.imageDetail(medium)]
            ))
            if !medium.tags.isEmpty {
                result.append(Section(
                    model: .imageTags,
                    items: medium.tags.toArray().map(CellStyle.imageTag)
                ))
            }
            if !items.isEmpty {
                result.append(Section(
                    model: .recommendMedia,
                    items: items.map(CellStyle.recommendMedium)
                ))
            }
            return result
        }
    }
}


