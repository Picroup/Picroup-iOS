//
//  ImageCommentsPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/20.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources

class ImageCommentsPresenter: NSObject {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lifeBar: UIView!
    @IBOutlet weak var lifeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var starPlaceholderView: UIView!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var sendButton: FlatButton!
    @IBOutlet weak var hideCommentsIcon: UIImageView!
    @IBOutlet weak var hideCommentsContentView: UIView!
    @IBOutlet weak var tableViewBackgroundButton: UIButton!
    
    func setup() {
        tableView.backgroundView = tableViewBackgroundButton
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        hideCommentsIcon.image = Icon.cm.arrowDownward
    }
    
    var medium: Binder<RankedMediaQuery.Data.RankedMedium.Item> {
        return Binder(self) { me, medium in
            me.imageView.setImage(with: medium.minioId)
            me.imageView.motionIdentifier = medium.id
            me.lifeBar.motionIdentifier = "lifeBar_\(medium.id)"
            me.sendButton.motionIdentifier = "starButton_\(medium.id)"
            me.lifeViewWidthConstraint.constant = CGFloat(medium.endedAt.sinceNow / 8.0.weeks) * me.lifeBar.bounds.width
            me.commentsCountLabel.text = "\(medium.commentsCount) 条"
        }
    }
    
    typealias Section = AnimatableSectionModel<String, MediumCommentsQuery.Data.Medium.Comment.Item>
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<Section>
    
    var items: (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(configureCell: { (dataSource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            cell.configure(with: item)
            return cell
        })
        return tableView.rx.items(dataSource: dataSource)
    }
}

class CommentCell: RxTableViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configure(with item: MediumCommentsQuery.Data.Medium.Comment.Item) {
//        userLabel?.text = item.userId
        contentLabel?.text = item.content
        photoView.setImage(with: item.user.avatarId) // crash if user if create new comment
    }
}

extension MediumCommentsQuery.Data.Medium.Comment.Item: IdentifiableType, Equatable {
    
    public typealias Identity = String
    public var identity: String {
        return id
    }
    
    public static func ==(lhs: MediumCommentsQuery.Data.Medium.Comment.Item, rhs: MediumCommentsQuery.Data.Medium.Comment.Item) -> Bool {
        return true
    }
}
