//
//  SpinnerButton.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/13.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit

class SpinnerButton: UIButton {
    
    var spinner: UIActivityIndicatorView!
    private var originDisableImage: UIImage?
    private var sppinning: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        prepareSpinner()
    }
    
    private func prepareSpinner() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.hidesWhenStopped = true
        spinner.sizeToFit()
        addSubview(spinner)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let spinner = spinner {
            spinner.frame.origin = CGPoint(
                x: (frame.width - spinner.frame.width) / 2,
                y: (frame.height - spinner.frame.height) / 2
            )
        }
    }
    
    func startSpinning() {
        // there's something wrong when embed this view in reusable cell
        // so i have to write this as following order
        
        isEnabled = false
        spinner.startAnimating()
        
        if sppinning { return }
        sppinning = true

        originDisableImage = image(for: .disabled)
        setImage(UIImage.createWithColor(.clear), for: .disabled)
        
    }
    
    func stopSpinning() {
        isEnabled = true
        spinner.stopAnimating()
        
        if !sppinning { return }
        sppinning = false

        setImage(originDisableImage, for: .disabled)
        originDisableImage = nil
    }
}

