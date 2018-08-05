//
//  FeedbackPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/5.
//  Copyright © 2018年 luojie. All rights reserved.
//


import UIKit
import Material
import RxSwift
import RxCocoa

class FeedbackPresenter: NSObject {
//    @IBOutlet weak var headerView: UIView!
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView! {
        didSet { textView.becomeFirstResponder() }
    }
    @IBOutlet weak var saveButton: RaisedButton!
    
    func setup(navigationItem: UINavigationItem) {
        navigationItem.titleLabel.text = " "
        navigationItem.titleLabel.textColor = .primaryText
    }
}
