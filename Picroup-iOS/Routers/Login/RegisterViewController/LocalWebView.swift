//
//  AboutAppViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/12.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

/// Web View Load Local Resource
class LocalWebView: UIWebView {
    @IBInspectable
    var fileName: String = "" {
        didSet {
            guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else { return }
            let url = URL(fileURLWithPath: path)
            let request = URLRequest(url: url)
            loadRequest(request)
        }
    }
}
