//
//  ImageDetailStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxFeedback

extension ImageDetailStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        queryMedium: @escaping (MediumQuery) -> Single<MediumQuery.Data.Medium?>,
        starMedium: @escaping (StarMediumMutation) -> Single<StarMediumMutation.Data.StarMedium>,
        deleteMedium: @escaping (DeleteMediumMutation) -> Single<String>,
        blockMedium: @escaping (BlockMediumMutation) -> Single<UserFragment>,
        shareMedium: @escaping (ShareMediumQueryStateObject.Query) -> Single<Void>
        ) -> Driver<ImageDetailStateObject> {
        
        let queryMediumFeedback: DriverFeedback = react(query: { $0.mediumQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return queryMedium(query)
                .map(Event.onGetData)
                .asSignal(onErrorReturnJust: Event.onGetError)
        })
        
        let starMediumFeedback: DriverFeedback = react(query: { $0.starMediumQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return starMedium(query)
                .map(Event.onStarMediumSuccess)
                .asSignal(onErrorReturnJust: Event.onStarMediumError)
        })
        
        let deleteMediumFeedback: DriverFeedback = react(query: { $0.deleteMediumQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return deleteMedium(query)
                .map(Event.onDeleteMediumSuccess)
                .asSignal(onErrorReturnJust: Event.onDeleteMediumError)
        })
        
        let blockMediumFeedback: DriverFeedback = react(query: { $0.blockUserQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return blockMedium(query)
                .map(Event.onBlockMediumSuccess)
                .asSignal(onErrorReturnJust: Event.onBlockMediumError)
        })
        
        let shareMediumFeedback: DriverFeedback = react(query: { $0.shareMediumQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return shareMedium(query)
                .map {  Event.onShareMediumSuccess }
                .asSignal(onErrorReturnJust: Event.onShareMediumError)
        })
        
        return system(
            feedbacks: [uiFeedback, queryMediumFeedback, starMediumFeedback, deleteMediumFeedback, blockMediumFeedback, shareMediumFeedback],
            //            composeStates: { $0.debug("ImageDetailState", trimOutput: false) },
            composeEvents: { $0.debug("ImageDetailState.Event", trimOutput: true) }
        )
    }
}
