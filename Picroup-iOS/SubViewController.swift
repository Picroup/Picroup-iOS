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


struct SubViewConnector {
    
    static let mapParentStateToChildEvent: (Driver<AppState>) -> Signal<SubViewState.Event> = { parentState in
        return .empty()
    }
    
    static let mapChildStateToParentEvent: (Driver<SubViewState>) -> Signal<AppState.Event> = { childState in
        return .empty()
    }
    
    
    static let connect: (Driver<AppState>) -> Signal<AppState.Event> = { parentState in
        let parentEvent = PublishRelay<AppState.Event>()
        let childFeedback: (Driver<SubViewState>) -> Signal<SubViewState.Event> = bind { (childState) in
            Bindings(subscriptions: [
                mapChildStateToParentEvent(childState).emit(to: parentEvent)
            ], events: [
                mapParentStateToChildEvent(parentState)
            ])
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SubViewController") as! SubViewController
        vc.dependency = childFeedback
        
        return parentEvent.asSignal()
    }
    
}

struct SubViewState {
    let display: String
    let callback: Void?
    
    static var empty: SubViewState {
        return SubViewState(display: "", callback: nil)
    }
    
    enum Event {
        case setDisplay(String)
        case triggerCallback
    }
    
    static let reduce: (SubViewState, Event) -> SubViewState = { state, event in
        switch event {
        case .setDisplay(let display):
            return SubViewState(
                display: display,
                callback: nil
            )
        case .triggerCallback:
            return SubViewState(
                display: state.display,
                callback: ()
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
            feedback: [{ state in dependency.event }]
            )
            .debug("SubViewState")
            .drive(dependency.state)
            .disposed(by: disposeBag)
        
        
    }
}

