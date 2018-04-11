//
//  CreateImageState.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import UIKit
import RxAlamofire

struct CreateImageState: Mutabled {
    let userId: String
    let pickedImage: UIImage
    var selectedCategory: MediumCategory
    var progress: RxProgress?
    var error: Error?
    var savedMedia: SaveImageMediumMutation.Data.SaveImageMedium?
    var triggerSave: (userId: String, pickedImage: UIImage, selectedCategory: MediumCategory)?
    var triggerCancel: Void?
}

extension CreateImageState {
    var isSavingImage: Bool { return triggerSave != nil }
    var shouldSaveImage: Bool { return !isSavingImage && savedMedia == nil }
}

extension CreateImageState {
    
    static func empty(userId: String = "5aca11401df3b96530ed221e", pickedImage: UIImage) -> CreateImageState {
        return CreateImageState(
            userId: userId,
            pickedImage: pickedImage,
            selectedCategory: .popular,
            progress: nil,
            error: nil,
            savedMedia: nil,
            triggerSave: nil,
            triggerCancel: nil
        )
    }
}

extension CreateImageState: IsFeedbackState {
    enum Event {
        case onSelectedCategory(MediumCategory)
        case onProgress(RxProgress)
        case onError(Error)
        case onSavedMedium(SaveImageMediumMutation.Data.SaveImageMedium)
        case triggerSave
        case triggerCancel
    }
}

extension CreateImageState {
    
    static func reduce(state: CreateImageState, event: CreateImageState.Event) -> CreateImageState {
        switch event {
        case .onSelectedCategory(let category):
            return state.mutated {
                $0.selectedCategory = category
            }
        case .onProgress(let progress):
            return state.mutated {
                $0.progress = progress
            }
        case .onError(let error):
            return state.mutated {
                $0.error = error
                $0.savedMedia = nil
                $0.triggerSave = nil
            }
        case .onSavedMedium(let medium):
            return state.mutated {
                $0.error = nil
                $0.savedMedia = medium
                $0.triggerSave = nil
            }
        case .triggerSave:
            guard state.shouldSaveImage else { return state }
            return state.mutated {
                $0.triggerSave = ($0.userId, $0.pickedImage, $0.selectedCategory)
            }
        case .triggerCancel:
            return state.mutated {
                $0.triggerCancel = ()
            }
        }
    }
}
