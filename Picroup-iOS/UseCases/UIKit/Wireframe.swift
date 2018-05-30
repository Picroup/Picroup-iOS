//
//  Wireframe.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//
import RxSwift

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif

protocol Wireframe {
    func open(url: URL)
    func promptFor<Action: CustomStringConvertible>(title: String?, message: String?, preferredStyle: UIAlertControllerStyle, cancelAction: Action, actions: [Action]) -> Observable<Action>
}


class DefaultWireframe: Wireframe {
    static let shared = DefaultWireframe()
    
    func open(url: URL) {
        #if os(iOS)
            UIApplication.shared.openURL(url)
        #elseif os(macOS)
            #if swift(>=4.0)
                NSWorkspace.shared.open(url)
            #else
                NSWorkspace.shared.open(url)
            #endif
        #endif
    }
    
    #if os(iOS)
    private static func rootViewController() -> UIViewController {
        // cheating, I know
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    #endif
    
    func promptFor<Action : CustomStringConvertible>(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle = .actionSheet, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        #if os(iOS)
            return Observable.create { observer in
                let alertView = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
                alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
                    observer.on(.next(cancelAction))
                })
                
                for action in actions {
                    alertView.addAction(UIAlertAction(title: action.description, style: .default) { _ in
                        observer.on(.next(action))
                    })
                }
                
                DefaultWireframe.rootViewController().present(alertView, animated: true, completion: nil)
                
                return Disposables.create {
                    alertView.dismiss(animated:false, completion: nil)
                }
            }
        #elseif os(macOS)
            return Observable.error(NSError(domain: "Unimplemented", code: -1, userInfo: nil))
        #endif
    }
}

