//
//  AppDelegate.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/3/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let routerService = RouterService(rootViewController: window!.rootViewController!)
        
        Driver.system(
            initialState: AppState.empty,
            reduce: AppState.reduce,
            feedback: { state in
                state.map { $0.routerState.triggerLogin }.distinctUntilChanged(==).filter { $0 != nil }.flatMap { _ -> Signal<AppState.Event> in
                    let event = PublishRelay<AppState.Event>()
                    routerService.showSubState(state: state, event: Binder(event) { $0.accept($1) })
                    return event.asSignal()
                }
        }, { _ in
            Signal.just(AppState.Event.routerEvent(.onTriggerLogin)).delay(3)
        })
            .debug("AppState")
            .drive()
            .disposed(by: disposeBag)
        
        return true
    }

}

