//
//  LoadFooterView.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/28.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

public enum LoadFooterViewState {
    case empty
    case loading
    case error(String)
    case loadedAll
}

public final class LoadFooterView: UIView {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("\(LoadFooterView.self)", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    public func on(_ state: LoadFooterViewState) {
        switch state {
        case .empty:
            label.isHidden = true
            spinner.stopAnimating()
        case .loading:
            label.isHidden = true
            spinner.startAnimating()
        case .error(let message):
            label.isHidden = false
            label.text = message
            spinner.stopAnimating()
        case .loadedAll:
            label.isHidden = false
            label.text = "已全部加载"
            spinner.stopAnimating()
        }
    }
}
