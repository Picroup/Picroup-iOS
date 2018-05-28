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

class LoginViewPresenter {
    
    var usernameField: ErrorTextField!
    var passwordField: TextField!
    var loginButton: RaisedButton!
    var registerButton: FlatButton!
    weak var view: UIView!
    weak var navigationItem: UINavigationItem!

    fileprivate let constant: CGFloat = 32
    
    func setup(view: UIView, navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        self.view = view
        view.backgroundColor = Color.grey.lighten5
        prepareNavigationItem()
        prepareResignResponderButton()
        preparePasswordField()
        prepareUsernameField()
    }
    
    fileprivate func prepareNavigationItem() {
//        navigationItem.titleLabel.text = "登录"
//        navigationItem.titleLabel.textColor = .primaryText
        registerButton = FlatButton(title: "注册", titleColor: .primaryText)
        navigationItem.rightViews = [registerButton]
    }
    
    fileprivate func prepareResignResponderButton() {
        loginButton = RaisedButton(title: "登录", titleColor: .primaryText)
        loginButton.backgroundColor = .secondary
        loginButton.isEnabled = true
        view.layout(loginButton).center(offsetX: 100).width(100).height(constant)
    }
    
    fileprivate func prepareUsernameField() {
        usernameField = ErrorTextField()
        usernameField.placeholder = "用户名"
        usernameField.detail = "至少需要 5 个字"
        usernameField.isClearIconButtonEnabled = true
        usernameField.placeholderActiveColor = .primary
        usernameField.dividerActiveColor = .primary
        usernameField.autocapitalizationType = .none
        
        view.layout(usernameField).center(offsetY: -loginButton.bounds.height - passwordField.bounds.height - 120).width(300)
    }
    
    fileprivate func preparePasswordField() {
        passwordField = TextField()
        passwordField.placeholderActiveColor = .primary
        passwordField.dividerActiveColor = .primary
        passwordField.placeholder = "密码"
        passwordField.detail = "至少需要 5 个字"
        passwordField.clearButtonMode = .whileEditing
        passwordField.isVisibilityIconButtonEnabled = true
        
        passwordField.detailColor = Color.red.base
        
        // Setting the visibilityIconButton color.
        passwordField.visibilityIconButton?.tintColor = .primary
        
        view.layout(passwordField).center(offsetY: -loginButton.bounds.height - 60).width(300)
    }
    

}

