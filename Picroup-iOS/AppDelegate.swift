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
import Material
import Apollo

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        prepareWindow()
        setupRxfeedback()
        return true
    }
    
    private func prepareWindow() {
        let window = UIWindow(frame: Screen.bounds)
        window.tintColor = UIColor.primary
        window.makeKeyAndVisible()
        window.rootViewController = RouterService.Main.rootViewController()
        self.window = window
    }
    
    private func setupRxfeedback() {
        _ = store.state.debug("state").map { $0.currentUser != nil }.distinctUntilChanged().drive(Binder(window!) { (window, isLogin) in
            let lvc = RouterService.Login.loginViewController(client: .shared, store: store)
            let loginViewController = SnackbarController(rootViewController: lvc)
            let rootViewController = RouterService.Main.rootViewController()
            window.rootViewController = isLogin ? rootViewController : loginViewController
        })
        
    }
}
