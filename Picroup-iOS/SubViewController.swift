//
//  SubViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/5.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

struct SubViewState {
    let display: String
    let trigger: Void?
    
    static var empty: SubViewState {
        return SubViewState(display: "", trigger: nil)
    }
    
    enum Event {
        case setDisplay(String)
        case trigger
    }
    
    static let reduce: (SubViewState, Event) -> SubViewState = { state, event in
        switch event {
        case .setDisplay(let display):
            return SubViewState(
                display: display,
                trigger: nil
            )
        case .trigger:
            return SubViewState(
                display: state.display,
                trigger: ()
            )
        }
    }
}

class SubViewController: UIViewController {

    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var label: UILabel!
    
    private let disposeBag = DisposeBag()
    var dependency: ((Driver<SubViewState>) -> Signal<SubViewState.Event>)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let dependency = dependency else { return }
        
        Driver<Any>.system(
            initialState: SubViewState.empty,
            reduce: SubViewState.reduce,
            feedback:
            dependency,
            bind(self) { (me, state) in
                Bindings(subscriptions: [
                    state.map { $0.display }.drive(me.label.rx.text)
                    ], events: [
                        me.button.rx.tap.asSignal().map { .trigger }
                    ])
            }
            )
            .debug("SubViewState")
            .drive()
            .disposed(by: disposeBag)
        
        
    }
}

