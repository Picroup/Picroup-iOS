//
//  MainTabBarController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

final class MainTabBarController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        tabBar.isTranslucent = false
//        hidesBottomBarWhenPushed = true
    }
    
    private var disposeBag = DisposeBag()
    
    override var viewControllers: [UIViewController]? {
        didSet {
            disposeBag = DisposeBag()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: setupRx)
        }
    }
    
    private func setupRx() {
        
        guard let nvc = viewControllers?.first(where: { ($0 as? BaseNavigationController)?.viewControllers.first is NotificationsViewController }),
            let appStateService = appStateService,
            let appStore = appStateService.appStore
            else { return }
        
        appStore.me()
            .map { $0.badgeValue }
            .drive(nvc.tabBarItem.rx.badgeValue)
            .disposed(by: disposeBag)
        
    }
}

extension UserObject {
    fileprivate var badgeValue: String? {
        if let notificationsCount = notificationsCount.value, notificationsCount > 0 {
            return notificationsCount.description
        }
        return nil
    }
}

