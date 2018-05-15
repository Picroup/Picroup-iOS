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
    var router: Router?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        prepareWindow()
        setupRouter()
        return true
    }
    
    private func prepareWindow() {
        let window = UIWindow(frame: Screen.bounds)
        window.tintColor = UIColor.primary
        window.makeKeyAndVisible()
        window.rootViewController = RouterService.Main.rootViewController()
        self.window = window
    }
    
    private func setupRouter() {
        router = Router(window: window!)
        router?.setupRxfeedback()
    }
}
