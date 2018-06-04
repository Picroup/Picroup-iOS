//
//  FeedbackViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/4.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

final class FeedbackViewController: HideNavigationBarViewController {
    
    @IBOutlet weak var textView: UITextView! {
        didSet { textView.becomeFirstResponder() }
    }
    
}
