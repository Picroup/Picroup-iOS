//
//  LoginViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxCocoa

final class LoginViewPresenter: NSObject {
    
    @IBOutlet weak var usernameField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var loginButton: RaisedButton!
    var registerButton: FlatButton!
//    weak var view: UIView!
    weak var navigationItem: UINavigationItem!

    fileprivate let constant: CGFloat = 32
    
    func setup(view: UIView, navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
//        self.view = view
//        view.backgroundColor = Color.grey.lighten5
        prepareNavigationItem()
        preparePasswordField()
        prepareUsernameField()
        prepareLoginButton()
    }
    
    fileprivate func prepareNavigationItem() {
//        navigationItem.titleLabel.text = "登录"
//        navigationItem.titleLabel.textColor = .primaryText
        registerButton = FlatButton(title: "注册", titleColor: .primaryText)
        navigationItem.rightViews = [registerButton]
    }
    
    fileprivate func prepareUsernameField() {
        usernameField.isClearIconButtonEnabled = true
        usernameField.placeholderActiveColor = .primary
        usernameField.dividerActiveColor = .primary
        usernameField.autocapitalizationType = .none
        usernameField.detailLabel.isHidden = true
//        _ = usernameField.becomeFirstResponder()
    }
    
    fileprivate func preparePasswordField() {
        passwordField.placeholderActiveColor = .primary
        passwordField.dividerActiveColor = .primary
        passwordField.clearButtonMode = .whileEditing
        passwordField.isVisibilityIconButtonEnabled = true
        passwordField.detailLabel.isHidden = true

//        passwordField.detailColor = Color.red.base
        
        // Setting the visibilityIconButton color.
        passwordField.visibilityIconButton?.tintColor = .primary
    }
    
    fileprivate func prepareLoginButton() {
        loginButton.backgroundColor = .secondary
        loginButton.isEnabled = true
    }

}

