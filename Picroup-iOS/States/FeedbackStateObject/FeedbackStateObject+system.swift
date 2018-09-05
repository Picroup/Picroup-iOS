//
//  FeedbackStateStore.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/23.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa
import RxFeedback

extension FeedbackStateObject {
    
    func system(
        uiFeedback: @escaping DriverFeedback,
        shouldQuery: @escaping () -> Bool,
        saveAppFeedback: @escaping (SaveAppFeedbackMutation) -> Single<String>,
        saveUserFeedback: @escaping (SaveUserFeedbackMutation) -> Single<String>,
        saveMediumFeedback: @escaping (SaveMediumFeedbackMutation) -> Single<String>,
        saveCommentFeedback: @escaping (SaveCommentFeedbackMutation) -> Single<String>
        ) -> Driver<FeedbackStateObject> {
        
        let saveAppFeedbackFeedback: DriverFeedback = react(query: { $0.saveAppFeedbackQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return saveAppFeedback(query)
                .map(Event.onSaveFeedbackSuccess)
                .asSignal(onErrorReturnJust: Event.onSaveFeedbackError)
        })
        
        let saveUserFeedbackFeedback: DriverFeedback = react(query: { $0.saveUserFeedbackQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return saveUserFeedback(query)
                .map(Event.onSaveFeedbackSuccess)
                .asSignal(onErrorReturnJust: Event.onSaveFeedbackError)
        })
        
        let saveMediumFeedbackFeedback: DriverFeedback = react(query: { $0.saveMediumFeedbackQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return saveMediumFeedback(query)
                .map(Event.onSaveFeedbackSuccess)
                .asSignal(onErrorReturnJust: Event.onSaveFeedbackError)
        })
        
        let saveCommentFeedbackFeedback: DriverFeedback = react(query: { $0.saveCommentFeedbackQuery }, effects: composeEffects(shouldQuery: shouldQuery) { query in
            return saveCommentFeedback(query)
                .map(Event.onSaveFeedbackSuccess)
                .asSignal(onErrorReturnJust: Event.onSaveFeedbackError)
        })
        
        return system(
            feedbacks: [uiFeedback, saveAppFeedbackFeedback, saveUserFeedbackFeedback, saveMediumFeedbackFeedback, saveCommentFeedbackFeedback],
            //            composeStates: { $0.debug("FeedbackState", trimOutput: false) },
            composeEvents: { $0.debug("FeedbackState.Event", trimOutput: true) }
        )
    }
}
