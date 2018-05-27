//
//  Router.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/15.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
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
        
        _ = store.reputationsRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .drive(Binder(self) { (me, _) in
                let vc = RouterService.Main.reputationsViewController()
                me.currentNavigationController?.pushViewController(vc, animated: true)
            })
        
        _ = store.pickImageRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .drive(Binder(self) { (me, _) in
                let vc = RouterService.Image.photoPickerController()
                me.currentNavigationController?.present(vc, animated: true)
            })
        
        _ = store.createImageRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .map { $0.imageKeys.toArray() }.filter { !$0.isEmpty }
            .drive(Binder(self) { (me, imageKeys) in
                print(imageKeys)
                let vc = RouterService.Image.createImageViewController(dependency: imageKeys)
                me.currentViewController?.present(SnackbarController(rootViewController: vc), animated: true)
            })
        
        _ = store.userRoute().distinctUntilChanged { $0.0.version ?? "" }.skip(1)
            .drive(Binder(self) { (me, userRouteInfo) in
                let (userRoute, isCurrentUser) = userRouteInfo
                let vc: UIViewController
                switch (isCurrentUser, userRoute.userId) {
                case (true, _):
                    vc = RouterService.Main.meViewController()
                    vc.hidesBottomBarWhenPushed = true
                    me.currentNavigationController?.pushViewController(vc, animated: true)
                case (false, let userId?):
                    vc = RouterService.Main.userViewController(dependency: userId)
                    me.currentNavigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            })
        
        _ = store.userFollowingsRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .map { $0.userId }.unwrap()
            .drive(Binder(self) { (me, userId) in
                let vc = RouterService.Main.followingsViewController(dependency: userId)
                me.currentNavigationController?.pushViewController(vc, animated: true)
            })
        
        _ = store.userFollowersRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .map { $0.userId }.unwrap()
            .drive(Binder(self) { (me, userId) in
                let vc = RouterService.Main.followersViewController(dependency: userId)
                me.currentNavigationController?.pushViewController(vc, animated: true)
            })
        
        _ = store.searchUserRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .drive(Binder(self) { (me, _) in
                let vc = RouterService.Main.searchUserViewController()
                me.currentNavigationController?.pushViewController(vc, animated: true)
            })
        
        _ = store.loginRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .drive(Binder(self) { (me, _) in
                let vc = RouterService.Login.loginViewController()
                let sc = SnackbarController(rootViewController: vc)
                me.currentNavigationController?.present(sc, animated: true)
            })
        
        _ = store.popRoute().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .drive(Binder(self) { (me, _) in
                me.currentNavigationController?.popViewController(animated: true)
            })
        
        _ = store.snackbar().distinctUntilChanged { $0.version ?? "" }.skip(1)
            .map { $0.message }.unwrap()
            .drive(Binder(self) { (me, message) in
                me.currentNavigationController?.snackbarController?.snackbar.text = message
                me.currentNavigationController?.snackbarController?.animate(snackbar: .visible)
                me.currentNavigationController?.snackbarController?.animate(snackbar: .hidden, delay: 3)
            })
        
        
        _ = store.session().debug("session").map { $0.isLogin }.distinctUntilChanged().drive(Binder(self) { (me, isLogin) in
            switch (isLogin, me.mainTabBarController) {
            case (false, nil):
                let mtvc: MainTabBarController = {
                    let result = RouterService.Main.mainTabBarController()
                    result.viewControllers = [
                        RouterService.Main.rankViewController(),
                    ]
                    return result
                }()
                me.mainTabBarController = mtvc
                me._window.rootViewController = mtvc
            case (true, nil):
                let mtvc: MainTabBarController = {
                    let result = RouterService.Main.mainTabBarController()
                    result.viewControllers = [
                        RouterService.Main.homeMenuViewController(),
                        RouterService.Main.rankViewController(),
                        RouterService.Main.notificationsViewController(),
                        RouterService.Main.meNavigationViewController(),
                    ]
                    return result
                }()
                me.mainTabBarController = mtvc
                me._window.rootViewController = mtvc
            case (false, let mainTabBarController?):
                mainTabBarController.viewControllers = [
                    RouterService.Main.rankViewController(),
                ]
            case (true, let mainTabBarController?):
                mainTabBarController.viewControllers = [
                    RouterService.Main.homeMenuViewController(),
                    RouterService.Main.rankViewController(),
                    RouterService.Main.notificationsViewController(),
                    RouterService.Main.meNavigationViewController(),
                ]
                
            }
        })
        
    }
}
