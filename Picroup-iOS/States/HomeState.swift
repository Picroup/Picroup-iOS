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
    
    var isFABMenuOpened: Bool
    var triggerFABMenuClose: Void?
    var triggerPickImage: UIImagePickerControllerSourceType?
    var pickedImage: UIImage?
}

extension HomeState {
    var isPickingImage: Bool { return triggerPickImage != nil }
}

extension HomeState {
    static var empty: HomeState {
        return HomeState(
            isFABMenuOpened: false,
            triggerFABMenuClose: nil,
            triggerPickImage: nil,
            pickedImage: nil
        )
    }
}

extension HomeState {
    
    enum Event {
        case fabMenuWillOpen
        case fabMenuWillClose
        case triggerFABMenuClose
        case triggerPickImage(UIImagePickerControllerSourceType)
        case pickedImage(UIImage)
        case pickeImageCancelled
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
                $0.pickedImage = nil
            }
        case .pickedImage(let image):
            return state.mutated {
                $0.triggerPickImage = nil
                $0.pickedImage = image
            }
        case .pickeImageCancelled:
            return state.mutated {
                $0.triggerPickImage = nil
                $0.pickedImage = nil
            }
        }
    }
}

