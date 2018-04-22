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
    
    var isFABMenuOpened: Bool
    var triggerFABMenuClose: Void?
    
    var triggerPickImage: UIImagePickerControllerSourceType?
    var saveMediumQuery: UIImage?

    var next: UserInterestedMediaQuery
    var items: [Item]
    var error: Error?
    var trigger: Bool
    
//    var router
//
//    struct Router {
//        var imageDetail: RankedMediaQuery.Data.RankedMedium.Item?
//        var imageComments: RankedMediaQuery.Data.RankedMedium.Item?
//    }
}

extension HomeState {
    var isPickingImage: Bool { return triggerPickImage != nil }
    var query: UserInterestedMediaQuery? {
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
}

extension HomeState {
    static func empty(userId: String) -> HomeState {
        return HomeState(
            isFABMenuOpened: false,
            triggerFABMenuClose: nil,
            triggerPickImage: nil,
            saveMediumQuery: nil,
            next: UserInterestedMediaQuery(userId: userId),
            items: [],
            error: nil,
            trigger: true
        )
    }
}

extension HomeState: IsFeedbackState {
    
    enum Event {
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
    }
}

extension HomeState {
    
    static func reduce(state: HomeState, event: Event) -> HomeState {
        switch event {
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
        }
    }
}

