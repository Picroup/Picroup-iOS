//
//  RxCollectionReusableView.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/28.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxCollectionReusableView: UICollectionReusableView {
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
}
