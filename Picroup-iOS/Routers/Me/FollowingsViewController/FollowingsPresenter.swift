//
//  FollowingsPresenter.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/5/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import UIKit
import Material
import RxSwift
import RxCocoa
import RxDataSources
import RxFeedback

private func onFollowButtonTap(_events: PublishRelay<UserFollowingsStateObject.Event>, item: UserObject)
    -> () -> Void {
        return {
            guard let followed = item.followed.value else { return }
            let event: UserFollowingsStateObject.Event = !followed ? .onTriggerFollowUser(item._id) : .onTriggerUnfollowUser(item._id)
            _events.accept(event)
        }
}

final class FollowingsPresenter: NSObject {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followingsCountLabel: UILabel!
    
    typealias Section = SectionModel<String, UserObject>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    var items: (PublishRelay<UserFollowingsStateObject.Event>) -> (Observable<[Section]>) -> Disposable {
        return { [tableView] _events in
            let dataSource = DataSource(
                configureCell: { dataSource, tableView, indexPath, item in
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                    let viewModel = UserViewModel(user: item)
                    cell.configure(
                        with: viewModel,
                        onFollowButtonTap: onFollowButtonTap(_events: _events, item: item)
                    )
                    return cell
            })
            return tableView!.rx.items(dataSource: dataSource)
        }
    }
}

class UserCell: RxTableViewCell {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var displaynameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: RaisedButton!
    
    func configure(with viewModel: UserViewModel, onFollowButtonTap: (()-> Void)?) {
        userAvatarImageView.setImage(with: viewModel.avatarId!)
        displaynameLabel.text = viewModel.username
        usernameLabel.text = viewModel.username
        FollowButtonPresenter.isSelected(base: followButton).onNext(viewModel.followed)
        if let onFollowButtonTap = onFollowButtonTap {
            followButton.rx.tap
                .subscribe(onNext: onFollowButtonTap)
                .disposed(by: disposeBag)
        }
    }
}

struct FollowButtonPresenter {
    
    static func isSelected(base: RaisedButton) -> Binder<Bool?> {
        return Binder(base) { button, isSelected in
//            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                guard let isSelected = isSelected else {
                    button.alpha = 0
                    return
                }
                button.alpha =  1
                if !isSelected {
                    button.backgroundColor = .primaryText
                    button.titleColor = .secondary
                    button.setTitle("关注", for: .normal)
                } else {
                    button.backgroundColor = .secondary
                    button.titleColor = .primaryText
                    button.setTitle("已关注", for: .normal)
                }
//            })
        }
    }
}
