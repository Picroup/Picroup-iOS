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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadFooterView: LoadFooterView!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var sendButton: FlatButton!
    @IBOutlet weak var sendCommentContentView: UIView!
    @IBOutlet weak var hideCommentsIcon: UIImageView!
    @IBOutlet weak var hideCommentsContentView: UIView!
    @IBOutlet weak var tableViewBackgroundButton: UIButton!
    @IBOutlet weak var deleteAlertView: UIView!
    @IBOutlet weak var suggestUpdateLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    weak var navigationItem: UINavigationItem!
    
    func setup(navigationItem: UINavigationItem) {
        self.navigationItem = navigationItem
        
        tableView.backgroundView = tableViewBackgroundButton
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        hideCommentsIcon.image = Icon.cm.arrowDownward
        
        navigationItem.titleLabel.text = "评论"
        navigationItem.titleLabel.textColor = .primaryText
        
        navigationItem.detailLabel.text = "0 条"
        navigationItem.detailLabel.textColor = .primaryText
    }
    
    var medium: Binder<MediumObject> {
        return Binder(self) { me, medium in
            let viewModel = ImageDetailViewModel(medium: medium)
            switch viewModel.kind {
            case MediumKind.image.rawValue?, MediumKind.video.rawValue?:
                me.imageView.setImage(with: medium.url)
                me.suggestUpdateLabel.isHidden = true
            default:
                me.imageView.image = nil
                me.suggestUpdateLabel.isHidden = false
            }
            me.imageView.backgroundColor = viewModel.placeholderColor
            me.imageView.motionIdentifier = viewModel.imageViewMotionIdentifier
            me.sendButton.motionIdentifier = viewModel.starButtonMotionIdentifier
            me.navigationItem.detailLabel.text = "\(viewModel.commentsCountText) 条  "
        }
    }
    
    typealias Section = AnimatableSectionModel<String, CommentObject>
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<Section>
    
    func items(onMoreButtonTap: @escaping (CommentObject) -> Void) -> (Observable<[Section]>) -> Disposable {
        let dataSource = DataSource(configureCell: { (dataSource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            cell.configure(
                with: item,
                onMoreButtonTap: { onMoreButtonTap(item) }
            )
            return cell
        })
        return tableView!.rx.items(dataSource: dataSource)
    }
    
    var isCommentsEmpty: Binder<Bool> {
        return Binder(self) { presenter, isEmpty in
            presenter.tableView.backgroundView = isEmpty ? presenter.emptyView : nil
        }
    }
}

