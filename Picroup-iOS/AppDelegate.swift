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
        
        Driver.system(
            initialState: AppState.empty,
            reduce: AppState.reduce,
            feedback: []
            )
            .debug("AppState")
            .drive()
            .disposed(by: disposeBag)
        
        return true
    }

}

