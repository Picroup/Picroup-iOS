//
//  RxFABMenuDelegateDelegateProxy.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//


import UIKit
import Material
import RxSwift
import RxCocoa

extension FABMenu: HasDelegate {
    public typealias Delegate = FABMenuDelegate
}

open class RxFABMenuDelegateDelegateProxy
    : DelegateProxy<FABMenu, FABMenuDelegate>
    , DelegateProxyType
, FABMenuDelegate {
    
    /// Typed parent object.
    public weak private(set) var fabMenu: FABMenu?
    
    /// - parameter navigationController: Parent object for delegate proxy.
    public init(fabMenu: ParentObject) {
        self.fabMenu = fabMenu
        super.init(parentObject: fabMenu, delegateProxy: RxFABMenuDelegateDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxFABMenuDelegateDelegateProxy(fabMenu: $0) }
    }
    
    lazy var _fabMenuWillOpen = { PublishRelay<Void>() }()
    lazy var _fabMenuWillClose = { PublishRelay<Void>() }()
    
    @objc
    open func fabMenuWillOpen(fabMenu: FABMenu) {
        _fabMenuWillOpen.accept(())
    }
    
    @objc
    open func fabMenuWillClose(fabMenu: FABMenu) {
        _fabMenuWillClose.accept(())
        
    }
}
