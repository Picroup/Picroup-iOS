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
    var selectedCategoryIndex: Int
    var progress: RxProgress?
    var error: Error?
    var savedMedia: SaveImageMediumMutation.Data.SaveImageMedium?
    var triggerSave: (userId: String, pickedImage: UIImage, selectedCategory: MediumCategory)?
    var triggerCancel: Void?
}

extension CreateImageState {
    var selectedCategory: MediumCategory { return MediumCategory.all[selectedCategoryIndex] }
    var isSavingImage: Bool { return triggerSave != nil }
    var shouldSaveImage: Bool { return !isSavingImage && savedMedia == nil }
}

extension CreateImageState {
    
    static func empty(userId: String = Config.userId, pickedImage: UIImage, selectedCategory: MediumCategory) -> CreateImageState {
        return CreateImageState(
            userId: userId,
            pickedImage: pickedImage,
            selectedCategoryIndex: MediumCategory.all.index(where: { $0 == selectedCategory }) ?? 0,
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
        case onSelectedCategoryIndex(Int)
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
        case .onSelectedCategoryIndex(let index):
            return state.mutated {
                $0.selectedCategoryIndex = index
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

extension MediumCategory {
    
    static var all: [MediumCategory] {
        return [
            .popular,
            .laughing,
            .beauty,
            .handsom,
            .animal,
            .photography,
            .design,
        ]
    }
    
    static var allCategories: [MediumCategory?] {
        return [nil] + MediumCategory.all
    }
    
    var name: String {
        switch self {
        case .popular:
            return "流行"
        case .laughing:
            return "搞笑"
        case .beauty:
            return "美女"
        case .handsom:
            return "帅哥"
        case .animal:
            return "动物"
        case .photography:
            return "摄影"
        case .design:
            return "设计"
        default:
            return rawValue
        }
    }
}
