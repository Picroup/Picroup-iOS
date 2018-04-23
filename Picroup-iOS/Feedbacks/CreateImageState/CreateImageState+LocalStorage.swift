//
//  CreateImageState+LocalStorage.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

extension DriverFeedback where State == CreateImageState {
    
    static func syncLocalStorage(_ localStorage: LocalStorage) -> Raw {
        return bind(localStorage) { (localStorage, state) in
            let subscriptions = [
                state.map { MediumCategory.all[$0.selectedCategoryIndex] }.drive(onNext: { localStorage.createImageSelectedCategory = $0 })
            ]
            let events = [
                Signal<CreateImageState.Event>.never()
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
    }
}

