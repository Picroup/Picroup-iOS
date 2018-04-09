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
    private let client = ApolloClient(url: URL(string: "\(Config.baseURL)/graphql")!)

    private let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: Screen.bounds)
        window.tintColor = UIColor.primary
//        let relay = PublishRelay<UserQuery.Data.User>()
//        let rootViewController = LoginViewController(dependency: (client, relay.accept))
//        RouterService.Login.loginViewController(client: client, observer: relay.accept)
        let rootViewController = RouterService.Main.mainViewController()
        window.rootViewController = SnackbarController(rootViewController: rootViewController)
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

}

