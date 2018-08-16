//
//  LoginService.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/9.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension RouterService {
    
    enum Login {}
}

extension RouterService.Login {
    
    static func loginViewController() -> LoginViewController {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        return vc
    }
    
    static func registerUsernameViewController() -> RegisterUsernameViewController {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "RegisterUsernameViewController") as! RegisterUsernameViewController
        return vc
    }
    
    static func resetPasswordViewController() -> ResetPasswordViewController {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        return vc
    }
    
    
}
