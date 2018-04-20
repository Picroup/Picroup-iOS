//
//  HomeViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxFeedback
import RxDataSources

class HomeViewController: UIViewController {
    
    typealias Dependency = (state: Driver<HomeState>, events: (HomeState.Event) -> Void)
    var dependency: Dependency!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let (state, events) = dependency else { return }
        typealias Feedback = (Driver<HomeState>) -> Signal<HomeState.Event>

        let uiFeedback: Feedback = bind(self) { (me, state) in
            return Bindings(subscriptions: [], events: [Signal<HomeState.Event>]())
        }
        
        uiFeedback(state)
            .emit(onNext: events)
            .disposed(by: disposeBag)
    }
}
