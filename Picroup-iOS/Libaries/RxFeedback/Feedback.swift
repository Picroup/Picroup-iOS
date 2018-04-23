//
//  Feedback.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

// Just a name space for feedback function so that we can extent it easier.

public struct DriverFeedback<State: IsFeedbackState> {
    typealias Raw = RxCocoa.Driver<Any>.Feedback<State, State.Event>
}

public struct ObservableFeedback<State: IsFeedbackState> {
    typealias Raw = RxSwift.Observable<Any>.Feedback<State, State.Event>
}
