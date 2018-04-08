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
            feedback: connect(
                keyed: { $0.routerState.triggerLogin },
                mapChildStateToParentEvent: { childState in
                    childState.map { $0.trigger }.unwrap().map { _ in .routerEvent(.onTriggerLogin) }
                        .debug("parentEvent")
                        .asSignal(onErrorRecover: { _ in .empty() })
                    
            },
                route: { (_, childFeedback) in
                    routerService.showSubState(dependency: childFeedback)
            }
            ), { _ in
                Signal.just(.routerEvent(.onTriggerLogin)).delay(3)
        })
            .debug("AppState")
            .drive()
            .disposed(by: disposeBag)
        
        return true
    }

}

