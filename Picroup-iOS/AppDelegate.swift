//
//  AppDelegate.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/3/19.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import Kingfisher

var appStateService: AppStateService?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var router: Router?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        prepareKingfisher()
        prepareWindow()
        setupRealm()
        setupAV()
        setupRouter()
        setupAppStateService()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        appStateService?.events.accept(.onTriggerReloadMe)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        HYDefaultCacheService.shared?.removeExpiredObjects()
    }
    
    private func prepareKingfisher() {
        ImageCache.default.maxDiskCacheSize = Config.maxDiskImageCacheSize
    }
    
    private func prepareWindow() {
        let window = UIWindow(frame: Screen.bounds)
        window.tintColor = UIColor.primary
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func setupRealm() {
        RealmProvider.setup()
    }
    
    private func setupAV() {
        AVHelper.setup()
    }
    
    private func setupRouter() {
        router = Router(window: window!)
        router!.setupRxfeedback()
    }
    
    private func setupAppStateService() {
        appStateService = AppStateService()
        appStateService!.setupRxfeedback()
    }
}
