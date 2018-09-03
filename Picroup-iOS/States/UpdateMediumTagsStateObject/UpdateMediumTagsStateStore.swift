//
//  UpdateMediumTagsStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm
import RxFeedback

extension UpdateMediumTagsStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        addTag: @escaping (MediumAddTagQuery) -> Single<MediumFragment>,
        remeveTag: @escaping (MediumRemoveTagQuery) -> Single<MediumFragment>
        ) -> Driver<UpdateMediumTagsStateObject> {
        
        let addTagFeedback: DriverFeedback = react(query: { $0.addTagQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return addTag(query)
                .map(Event.onAddTagSuccess)
                .asSignal(onErrorReturnJust: { .onAddTagError($0, query.tag) })
        })
        
        let remeveTagFeedback: DriverFeedback = react(query: { $0.removeTagQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return remeveTag(query)
                .map(Event.onRemoveTagSuccess)
                .asSignal(onErrorReturnJust: { .onRemoveTagError($0, query.tag) })
        })
        
        return system(
            feedbacks: [uiFeedback, addTagFeedback, remeveTagFeedback],
            //            composeStates: { $0.debug("UpdateMediumTagsState", trimOutput: false) },
            composeEvents: { $0.debug("UpdateMediumTagsState.Event", trimOutput: true) }
        )
    }
}
