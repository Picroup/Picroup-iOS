//
//  UpdatePasswordPresenter.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/28.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material

final class UpdatePasswordPresenter: NSObject {
    @IBOutlet weak var oldPasswordField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var setPasswordButton: RaisedButton!
    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareNavigationItem()
        prepareOldPasswordField()
        preparePasswordField()
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "修改密码"
        navigationItem.titleLabel.textColor = .primaryText
    }
    
    fileprivate func prepareOldPasswordField() {
        oldPasswordField.placeholderActiveColor = .primary
        oldPasswordField.dividerActiveColor = .primary
        oldPasswordField.clearButtonMode = .whileEditing
        oldPasswordField.isVisibilityIconButtonEnabled = true
        //        _ = oldPasswordField.becomeFirstResponder()
    }
    
    fileprivate func preparePasswordField() {
        passwordField.placeholderActiveColor = .primary
        passwordField.dividerActiveColor = .primary
        passwordField.clearButtonMode = .whileEditing
        passwordField.isVisibilityIconButtonEnabled = true
    }
}
