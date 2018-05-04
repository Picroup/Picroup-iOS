//
//  AppState+Route.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Material

extension DriverFeedback where State == AppState {
    
    static func showMainViewController(window: UIWindow) -> Raw {
        return react(query: { $0.currentUserState.user }) { _ in
            window.rootViewController = RouterService.Main.rootViewController()
            return .empty()
        }
    }
    
    static func showLoginViewController(window: UIWindow) -> Raw {
        return react(query: { $0.currentUserState.logoutQuery }) { _ in
            let lvc = RouterService.Login.loginViewController(client: .shared, store: .shared)
            window.rootViewController = SnackbarController(rootViewController: lvc)
            return .empty()
        }
    }
}

