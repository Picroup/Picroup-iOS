//
//  HomeState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import UIKit

enum PickImageKind {
    case camera
    case photo
}

struct HomeState: Mutabled {
    typealias Item = UserInterestedMediaQuery.Data.User.InterestedMedium.Item
    
    var currentUser: UserDetailFragment?
    
    var isFABMenuOpened: Bool
    var triggerFABMenuClose: Void?
    
    var triggerPickImage: UIImagePickerControllerSourceType?
    var saveMediumQuery: UIImage?

    var next: UserInterestedMediaQuery
    var items: [Item]
    var error: Error?
    var trigger: Bool
    
    var nextShowCommentsIndex: Int?
    var nextShowImageDetailIndex: Int?
}

extension HomeState {
    var isPickingImage: Bool { return triggerPickImage != nil }
    var query: UserInterestedMediaQuery? {
        if (currentUser == nil) { return nil }
        return trigger ? next : nil
    }
    var shouldQueryMore: Bool {
        return !trigger && next.cursor != nil
    }
    var isItemsEmpty: Bool {
        return !trigger && error == nil && items.isEmpty
    }
    var hasMore: Bool {
        return next.cursor != nil
    }
    var showCommentsQuery: Item? {
        guard let index = nextShowCommentsIndex else { return nil }
        return items[index]
    }
    var showImageDetailQuery: Item? {
        guard let index = nextShowImageDetailIndex else { return nil }
        return items[index]
    }
}

extension HomeState {
    static func empty() -> HomeState {
        return HomeState(
            currentUser: nil,
            isFABMenuOpened: false,
            triggerFABMenuClose: nil,
            triggerPickImage: nil,
            saveMediumQuery: nil,
            next: UserInterestedMediaQuery(userId: ""),
            items: [],
            error: nil,
            trigger: true,
            nextShowCommentsIndex: nil,
            nextShowImageDetailIndex: nil
        )
    }
}

extension HomeState: IsFeedbackState {
    
    enum Event {
        case onUpdateCurrentUser(UserDetailFragment?)
        case fabMenuWillOpen
        case fabMenuWillClose
        case triggerFABMenuClose
        
        case triggerPickImage(UIImagePickerControllerSourceType)
        case pickedImage(UIImage)
        case pickeImageCancelled
        case onSeveMediumSuccess(CreateImageState.SaveImageMedium)
        case onSeveMediumCancelled
        
        case onTriggerReload
        case onTriggerGetMore
        case onGetSuccess(UserInterestedMediaQuery.Data.User)
        case onGetError(Error)
        
        case onTriggerShowComments(Int)
        case onShowCommentsCompleted
        
        case onTriggerShowImageDetail(Int)
        case onShowImageDetailCompleted
    }
}

extension HomeState {
    
    static func reduce(state: HomeState, event: Event) -> HomeState {
        switch event {
        case .onUpdateCurrentUser(let currentUser):
            return state.mutated {
                $0.currentUser = currentUser
                $0.next.userId = currentUser?.id ?? ""
            }
        case .fabMenuWillOpen:
            return state.mutated {
                $0.isFABMenuOpened = true
                $0.triggerFABMenuClose = nil
            }
        case .fabMenuWillClose:
            return state.mutated {
                $0.isFABMenuOpened = false
                $0.triggerFABMenuClose = nil
            }
        case .triggerFABMenuClose:
            return state.mutated {
                $0.isFABMenuOpened = false
                $0.triggerFABMenuClose = ()
            }
        case .triggerPickImage(let sourceType):
            guard !state.isPickingImage else { return state }
            return state.mutated {
                $0.triggerPickImage = sourceType
                $0.saveMediumQuery = nil
            }
        case .pickedImage(let image):
            return state.mutated {
                $0.triggerPickImage = nil
                $0.saveMediumQuery = image
            }
        case .pickeImageCancelled:
            return state.mutated {
                $0.triggerPickImage = nil
                $0.saveMediumQuery = nil
            }
        case .onSeveMediumSuccess(let savedMedium):
            return state.mutated {
                let item = Item(snapshot: savedMedium.snapshot)
                $0.items.insert(item, at: 0)
                $0.saveMediumQuery = nil
            }
        case .onSeveMediumCancelled:
            return state.mutated {
                $0.saveMediumQuery = nil
            }
        case .onTriggerReload:
            return state.mutated {
                $0.next.cursor = nil
                $0.items = []
                $0.error = nil
                $0.trigger = true
            }
        case .onTriggerGetMore:
            guard state.shouldQueryMore else { return state }
            return state.mutated {
                $0.error = nil
                $0.trigger = true
            }
        case .onGetSuccess(let data):
            return state.mutated {
                $0.next.cursor = data.interestedMedia.cursor
                $0.items += data.interestedMedia.items.flatMap { $0 }
                $0.error = nil
                $0.trigger = false
            }
        case .onGetError(let error):
            return state.mutated {
                $0.error = error
                $0.trigger = false
            }
        case .onTriggerShowComments(let index):
            return state.mutated {
                $0.nextShowCommentsIndex = index
            }
        case .onShowCommentsCompleted:
            return state.mutated {
                $0.nextShowCommentsIndex = nil
            }
        case .onTriggerShowImageDetail(let index):
            return state.mutated {
                $0.nextShowImageDetailIndex = index
            }
        case .onShowImageDetailCompleted:
            return state.mutated {
                $0.nextShowImageDetailIndex = nil
            }
        }
    }
}

