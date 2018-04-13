//
//  FABMenu+Rx.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Material
import RxSwift
import RxCocoa

extension Reactive where Base: FABMenu {
    public var delegate: RxFABMenuDelegateDelegateProxy {
        return RxFABMenuDelegateDelegateProxy.proxy(for: base)
    }
    
    public var fabMenuWillOpen: ControlEvent<Void> {
        return ControlEvent(events: delegate._fabMenuWillOpen)
    }
    
    public var fabMenuWillClose: ControlEvent<Void> {
        return ControlEvent(events: delegate._fabMenuWillClose)
    }
}

extension Reactive where Base: FABMenu {
    
    public func close() -> Binder<Void> {
        return Binder(base) { menu, _ in
            menu.close()
        }
    }
}

