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
import AVKit
import RealmSwift

private func mapMoreButtonTapToEvent(sender: UICollectionView) -> (ImageDetailStateObject) -> Signal<ImageDetailStateObject.Event> {
    return { state in
        
        guard state.sessionState?.isLogin == true else {
            return .just(.onTriggerLogin)
        }
        guard let cell = sender.cellForItem(at: IndexPath(item: 0, section: 0)) as? HasMoreButton else { return .empty() }
        let isMyMedium = state.mediumQueryState?.medium?.userId == state.sessionState?.currentUserId
        let actions: [String]
        switch (isMyMedium, state.sessionState?.currentUser?.reputation.value) {
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

final class ImageDetailViewController: ShowNavigationBarViewController, IsStateViewController {
    
    typealias State = ImageDetailStateObject
    typealias Event = State.Event
    
    typealias Dependency = String
    var dependency: Dependency!
    
    @IBOutlet var presenter: ImageDetailPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRxFeedback()
    }
    
    private func setupRxFeedback() {
        
        guard let mediumId = dependency,
            let realm = try? Realm(),
            let state = try? State.create(mediumId: mediumId)(realm) else { return }
        
        appStateService?.events.accept(.onViewMedium(mediumId))
        
        weak var weakSelf = self
        let _events = PublishRelay<Event>()
        let _moreButtonTap = PublishRelay<Void>()

        // I known this is ugly but it enable transition animations
        let rxState = state.rx.observe().share(replay: 1)
        
        let sections = Observable.combineLatest(state.sections, rxState) { $1.isMediumDeleted ? [] : $0 }
        let isSharing = rxState.map { $0.shareMediumQueryState?.trigger ?? false }.asDriverOnErrorRecoverEmpty()
        
        state.sections
            .bind(to: presenter.mediumDetailPresenter.items(
                isSharing: isSharing,
                onStarButtonTap: { mediumId in _events.accept(.onTriggerStarMedium(mediumId)) },
                onCommentsTap: { mediumId in _events.accept(.onTriggerShowComments(mediumId)) },
                onImageViewTap: { _ in _events.accept(.onTriggerPop) },
                onUserTap: { userId in _events.accept(.onTriggerShowUser(userId)) },
                onShareTap: { _ in _events.accept(.onTriggerShareMedium) },
                onMoreTap: { _ in _moreButtonTap.accept(()) })
            ).disposed(by: disposeBag)
        
        state.system(
            uiFeedback: uiFeedback(sections: sections, _events: _events, _moreButtonTap: _moreButtonTap),
            shouldQuery: { [weak self] in self?.shouldReactQuery ?? false  },
            queryMedium: { query in
                return ApolloClient.shared.rx.fetch(query: query, cachePolicy: .fetchIgnoringCacheData)
                    .map { $0?.data?.medium }
                    .delay(0.4, scheduler: MainScheduler.instance)
        },
            starMedium: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.starMedium }.forceUnwrap()
        },
            deleteMedium: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.deleteMedium }.forceUnwrap()
        },
            blockMedium: { query in
                return ApolloClient.shared.rx.perform(mutation: query)
                    .map { $0?.data?.blockMedium.fragments.userFragment }.forceUnwrap()
        },
            shareMedium: { query in
                let (username, mediumItem) = query
                switch mediumItem {
                case .image(let cacheKey):
                    let image = ImageCache.default.retrieveImage(forKey: cacheKey)!
                    return WatermarkService.addImageWatermark(image: image, username: username)
                        .observeOn(MainScheduler.instance)
                        .do(onSuccess: {  item in
                            let vc = UIActivityViewController(activityItems: [item], applicationActivities: nil)
                            weakSelf?.present(vc, animated: true, completion: nil)
                        })
                        .mapToVoid()
                case .video(thumbnailImageKey: _, videoFileURL: let videoURL):
                    let url = HYDefaultCacheService.shared?.fileURL(for: videoURL) ?? videoURL
                    return WatermarkService.addVideoWatermark(videoURL: url, username: username)
                        .observeOn(MainScheduler.instance)
                        .do(onSuccess: { item in
                            let vc = UIActivityViewController(activityItems: [item], applicationActivities: nil)
                            weakSelf?.present(vc, animated: true, completion: nil)
                        })
                        .mapToVoid()
                }
        })
            .drive()
            .disposed(by: disposeBag)
        
        presenter.collectionView.rx.setDelegate(presenter.mediumDetailPresenter).disposed(by: disposeBag)
    }
    
    fileprivate func uiFeedback(sections: Observable<[Section]>, _events: PublishRelay<Event>, _moreButtonTap: PublishRelay<Void>) -> State.DriverFeedback {
        return bind(self) { (me, state) in
            let presenter = me.presenter!
            let subscriptions = [
                sections.map { $0.isEmpty }.subscribe(onNext: { presenter.collectionView.backgroundView = $0 ? presenter.deleteAlertView : nil }),
                presenter.backgroundButton.rx.tap.subscribe(onNext: { _events.accept(.onTriggerPop) }),
                presenter.collectionView.rx.shouldHideNavigationBar().emit(to: me.rx.setNavigationBarHidden(animated: true)),
                ]
            let events: [Signal<Event>] = [
                .just(.onTriggerReloadData),
                _events.asSignal(),
                _moreButtonTap.asSignal().withLatestFrom(state).flatMapLatest(mapMoreButtonTapToEvent(sender: presenter.collectionView)),
                state.flatMapLatest {
                    ($0.mediumQueryState?.shouldQueryMore ?? false)
                        ? presenter.collectionView.rx.triggerGetMore
                        : .empty()
                    }.map { .onTriggerGetMoreData },
                me.presenter.collectionView.rx.modelSelected(MediumDetailPresenter.CellStyle.self).asSignal()
                    .flatMapLatest { cellStyle -> Signal<Event> in
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
    }
}

extension ImageDetailStateObject {
    
    fileprivate func medium() -> Observable<MediumObject> {
        guard let medium = mediumQueryState?.medium else { return .empty() }
        return medium.rx.observe().catchErrorJustReturn(medium)
    }
    
    fileprivate func recommendMediaItems() -> Observable<[MediumObject]> {
        guard let items = mediumQueryState?.recommendMedia?.items else { return .empty() }
        return items.rx.observe().map { $0.toArray() }.catchErrorRecoverEmpty()
    }
    
    fileprivate func mediumWithRecommendMedia() -> Observable<(MediumObject, [MediumObject])> {
        return Observable.combineLatest(medium(), recommendMediaItems())
            .catchErrorRecoverEmpty()
    }
    
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


