//
//  createFeedback.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/13.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

public func composeEffects<Query, Event>(predicate: @escaping () -> Bool, effects: @escaping (Query) -> Signal<Event>)
    -> (Query) -> Signal<Event> {
        return { query in
            let shouldQuery = predicate()
            guard shouldQuery else { return .empty() }
            return effects(query)
        }
}

