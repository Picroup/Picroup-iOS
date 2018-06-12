//
//  AboutAppViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/6/12.
//  Copyright © 2018年 luojie. All rights reserved.
//


import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

final class AboutAppViewController: HideNavigationBarViewController {
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.rx.tapGesture().when(.recognized)
            .mapToVoid().asSignalOnErrorRecoverEmpty()
            .emit(to: rx.pop())
            .disposed(by: disposeBag)
    }
}
