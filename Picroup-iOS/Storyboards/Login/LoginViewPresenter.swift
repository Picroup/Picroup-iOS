//
//  LoginViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/8.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

class LoginViewPresenter {
    
    var usernameField: ErrorTextField!
    var passwordField: TextField!
    var raisedButton: RaisedButton!
    let view: UIView

    fileprivate let constant: CGFloat = 32
    
    init(view: UIView) {
        self.view = view
        self.setup()
    }
    
    private func setup() {
        view.backgroundColor = Color.grey.lighten5
        prepareResignResponderButton()
        preparePasswordField()
        prepareUsernameField()
    }
    
    /// Prepares the resign responder button.
    fileprivate func prepareResignResponderButton() {
        raisedButton = RaisedButton(title: "登录", titleColor: .primaryText)
//        raisedButton.setBackgroundImage(UIImage.createWithColor(.secondary), for: .normal)
        raisedButton.backgroundColor = .secondary
        raisedButton.isEnabled = true
        view.layout(raisedButton).center().width(100).height(constant).right(20)
    }
    
    fileprivate func prepareUsernameField() {
        usernameField = ErrorTextField()
        usernameField.placeholder = "用户名"
        usernameField.detail = "用户名无效"
        usernameField.isClearIconButtonEnabled = true
        usernameField.placeholderActiveColor = .primary
        usernameField.dividerActiveColor = .primary
        
        view.layout(usernameField).center(offsetY: -raisedButton.bounds.height - passwordField.bounds.height - 120).left(20).right(20)
    }
    
    fileprivate func preparePasswordField() {
        passwordField = TextField()
        passwordField.placeholderActiveColor = .primary
        passwordField.dividerActiveColor = .primary
        passwordField.placeholder = "密码"
        passwordField.detail = "至少需要 8 个字"
        passwordField.clearButtonMode = .whileEditing
        passwordField.isVisibilityIconButtonEnabled = true
        
        passwordField.detailColor = Color.red.base
        
        // Setting the visibilityIconButton color.
        passwordField.visibilityIconButton?.tintColor = .primary
        
        view.layout(passwordField).center(offsetY: -raisedButton.bounds.height - 60).left(20).right(20)
    }
}

