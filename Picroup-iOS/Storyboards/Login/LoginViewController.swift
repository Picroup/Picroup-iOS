//
//  LoginViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

class LoginViewController: UIViewController {
    
    fileprivate var loginViewPresenter: LoginViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginViewPresenter = LoginViewPresenter(view: view!)
        
        loginViewPresenter.raisedButton.addTarget(self, action: #selector(handleResignResponderButton(button:)), for: .touchUpInside)
        loginViewPresenter.usernameField.delegate = self
    }
    
    /// Handle the resign responder button.
    @objc
    internal func handleResignResponderButton(button: UIButton) {
        loginViewPresenter.usernameField?.resignFirstResponder()
        loginViewPresenter.passwordField?.resignFirstResponder()
    }
}

extension LoginViewController: TextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? ErrorTextField)?.isErrorRevealed = false
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = true
        return true
    }
}
