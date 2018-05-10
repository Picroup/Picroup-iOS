//
//  NotificationsViewPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/25.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class NotificationsViewPresenter: NSObject {
    @IBOutlet weak var tableView: UITableView!
    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        prepareNavigationItem()
    }
    
    fileprivate func prepareNavigationItem() {
        navigationItem.titleLabel.text = "通知"
        navigationItem.titleLabel.textColor = .primaryText
    }
    
    typealias Section = AnimatableSectionModel<String, NotificationFragment>
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<Section>
    
    var items: (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
                cell.configure(with: item)
                return cell
        })
        return tableView.rx.items(dataSource: dataSource)
    }
}

class NotificationCell: RxTableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var mediumImageView: UIImageView!
    
    func configure(with item: NotificationFragment) {
        userAvatarImageView.setImage(with: item.user.avatarId)
        mediumImageView.setImage(with: item.medium?.minioId)
        switch item.kind {
        case .commentMedium:
            contentLabel.text = "评论了你的图片"
        case .starMedium:
            contentLabel.text = "给你的图片续命"
        case .followUser:
            contentLabel.text = "关注了你"
        default:
            contentLabel.text = "  "
        }
    }
}

extension NotificationFragment: IdentifiableType, Equatable {
    
    public var identity: String {
        return id
    }
    
    public static func ==(lhs: NotificationFragment, rhs: NotificationFragment) -> Bool {
        return true
    }
}

