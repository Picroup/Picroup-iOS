//
//  ReputationsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Apollo
import RxSwift
import RxCocoa
import RxFeedback

class ReputationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Driver.just([0]).drive(tableView.rx.items(cellIdentifier: "Cell")) { index, item, cell in
            
        }
        .disposed(by: disposeBag)
        
        view.rx.tapGesture().when(.recognized).mapToVoid()
            .bind(to: rx.pop(animated: true))
            .disposed(by: disposeBag)
    }
}
