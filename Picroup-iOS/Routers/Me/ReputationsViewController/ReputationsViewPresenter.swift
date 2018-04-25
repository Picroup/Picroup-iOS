//
//  ReputationsViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/24.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ReputationsViewPresenter: NSObject {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reputationCountLabel: UILabel!

    typealias Section = AnimatableSectionModel<String, MyReputationsQuery.Data.User.ReputationLink.Item>
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<Section>
    
    var items: (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReputationCell", for: indexPath) as! ReputationCell
                cell.configure(with: item)
                return cell
        })
        return tableView.rx.items(dataSource: dataSource)
    }
}

class ReputationCell: RxTableViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var mediumImageView: UIImageView!
    
    func configure(with item: MyReputationsQuery.Data.User.ReputationLink.Item) {
        valueLabel.text = "+\(item.value)"
        switch item.kind {
        case .saveMedium:
            contentLabel.text = "分享了图片"
        case .starMedium:
            contentLabel.text = "收藏了你的图片"
        case .followUser:
            contentLabel.text = "关注了你"
        default:
            contentLabel.text = "  "
        }
    }
}


extension MyReputationsQuery.Data.User.ReputationLink.Item: IdentifiableType, Equatable {
    
    public var identity: String {
        return id
    }
    
    public static func ==(lhs: MyReputationsQuery.Data.User.ReputationLink.Item, rhs: MyReputationsQuery.Data.User.ReputationLink.Item) -> Bool {
        return true
    }
}
