//
//  Router.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Material
import Apollo

final class Router {
    
    private let _window: UIWindow
    private var mainTabBarController: MainTabBarController?
    
    init(window: UIWindow) {
        _window = window
    }
    
    var currentNavigationController: UINavigationController? {
        return mainTabBarController?.selectedViewController as? UINavigationController
    }
    
    var currentViewController: UIViewController? {
        return currentNavigationController?.topViewController
    }
    
    func setupRxfeedback() {
        
        guard let store = try? RouteStateStore() else { return }
        
        _ = store.imageDetialRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .map { $0.mediumId }.unwrap()
            .drive(Binder(self) { (me, mediumId) in
                let vc = RouterService.Image.imageDetailViewController(dependency: mediumId)
                me.currentNavigationController?.pushViewController(vc, animated: true)
            })
        
        _ = store.imageCommetsRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .map { $0.mediumId }.unwrap()
            .drive(Binder(self) { (me, mediumId) in
                let vc = RouterService.Image.imageCommentsViewController(dependency: mediumId)
                me.currentNavigationController?.pushViewController(vc, animated: true)
            })
        
        _ = store.popRoute().debug("popRoute").distinctUntilChanged { $0.version ?? "" }.skip(1)
            .drive(Binder(self) { (me, _) in
                me.currentNavigationController?.popViewController(animated: true)
            })
        
//        _ = states.map { $0.session?.isLogin ?? false }.distinctUntilChanged().drive(Binder(_window) { (window, isLogin) in
//            let lvc = RouterService.Login.loginViewController(client: .shared, appStore: appStore)
//            let loginViewController = SnackbarController(rootViewController: lvc)
//            let rootViewController = RouterService.Main.rootViewController()
//            window.rootViewController = isLogin ? rootViewController : loginViewController
//        })
        
        _ = appStore.state.debug("state").map { $0.currentUser != nil }.distinctUntilChanged().drive(Binder(self) { (me, isLogin) in
            let lvc = RouterService.Login.loginViewController(client: .shared, appStore: appStore)
            if isLogin {
                let mainTabBarController = RouterService.Main.rootViewController()
                me.mainTabBarController = mainTabBarController
                me._window.rootViewController = SnackbarController(rootViewController: mainTabBarController)
            } else {
                let loginViewController = SnackbarController(rootViewController: lvc)
                me._window.rootViewController = loginViewController
            }
        })

        _ = appStore.state.map { $0.recommendMediumQuery }.distinctUnwrap().flatMapLatest {
            ApolloClient.shared.rx.perform(mutation: $0)
                .asSignal(onErrorJustReturn: nil)
            }.mapToVoid()
            .emit(onNext: appStore.onRecommendMediumCompleted)
        
    }
}
