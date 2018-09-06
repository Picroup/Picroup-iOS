//
//  CreateImageStateStore.swift
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

extension CreateImageStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        saveMedium: @escaping (String, MediumItem, [String]?) -> Observable<MediumService.SaveMediumResult>
        ) -> Driver<CreateImageStateObject> {
        
        let saveMediumsFeedback: DriverFeedback = react(query: { $0.saveQuery }, effects: composeEffects(shouldQuery: shouldQuery) { (query) in
            let (userId, mediaItems, tags) = query
            let queries: [Signal<Event>] = mediaItems.enumerated().map { index, mediaItem in
                return saveMedium(userId, mediaItem, tags)
                    .map(mapSaveMediumResultToEvent(index: index))
                    .asSignal(onErrorReturnJust: { .onSavedMediumError($0, index) })
            }
            return Signal.concat(queries)
        })
        
        return system(
            feedbacks: [uiFeedback, saveMediumsFeedback],
            //            composeStates: { $0.debug("CreateImageState", trimOutput: false) },
            composeEvents: { $0.debug("CreateImageState.Event", trimOutput: true) }
        )
    }
}

private func mapSaveMediumResultToEvent(index: Int) -> (MediumService.SaveMediumResult) -> CreateImageStateObject.Event {
    return { result in
        switch result {
        case .progress(let progress):
            return .onProgress(progress, index)
        case .completed(let medium):
            return .onSavedMediumSuccess(medium, index)
        }
    }
}
