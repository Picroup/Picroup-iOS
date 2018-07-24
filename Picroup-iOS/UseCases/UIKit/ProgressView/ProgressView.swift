//
//  ProgressView.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/7/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import UIKit

public final class ProgressView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var lifeViewWidthConstraint: NSLayoutConstraint!
    var progress: Float = 0 {
        didSet { updateLifeViewWidthConstraints() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("\(ProgressView.self)", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
}
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLifeViewWidthConstraints()
    }
    
    private func updateLifeViewWidthConstraints() {
        lifeViewWidthConstraint.constant = CGFloat(progress) * bounds.width
    }
}
