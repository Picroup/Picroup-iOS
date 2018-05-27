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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reputationCountLabel: UILabel!

    typealias Section = AnimatableSectionModel<String, ReputationObject>
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
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var mediumImageView: UIImageView!
    
    func configure(with item: ReputationObject) {
        guard !item.isInvalidated else { return }
        
        valueLabel.text = "+\(item.value.value ?? 0)"
        userAvatarImageView.setImage(with: item.user?.avatarId)
        mediumImageView.setImage(with: item.medium?.minioId)
        switch item.kind {
        case "saveMedium"?:
            contentLabel.text = "分享了图片"
        case "starMedium"?:
            contentLabel.text = "给你的图片续命"
        case "followUser"?:
            contentLabel.text = "关注了你"
        default:
            contentLabel.text = "  "
        }
    }
}

