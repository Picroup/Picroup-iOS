//
//  FollowingsViewController.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/21.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FollowingsViewController: HideNavigationBarViewController {
    @IBOutlet var presenter: FollowingsPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.just((0..<10).map { $0 }).bind(to: presenter.tableView.rx.items(cellIdentifier: "Cell")) { index, item, cell in
            
        }
        .disposed(by: disposeBag)
    }
}

final class FollowingsPresenter: NSObject {
    @IBOutlet weak var tableView: UITableView!
}
