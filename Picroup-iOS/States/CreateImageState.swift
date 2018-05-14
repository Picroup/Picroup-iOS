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
    typealias Query = (userId: String, pickedImage: UIImage)
    
    var currentUser: UserDetailFragment?
    
    var progress: RxProgress?
    var error: Error?
    var savedMedium: MediumFragment?
    var next: Query
    var triggerSave: Bool
    
    var triggerCancel: Void?
}

extension CreateImageState {
    var query: Query? {
        if (currentUser == nil) { return nil }
        return triggerSave ? next : nil
    }
    var shouldSaveImage: Bool {
        return !triggerSave && savedMedium == nil
    }
}

extension CreateImageState {
    
    static func empty(pickedImage: UIImage) -> CreateImageState {
        return CreateImageState(
            currentUser: nil,
            progress: nil,
            error: nil,
            savedMedium: nil,
            next: ("", pickedImage),
            triggerSave: false,
            triggerCancel: nil
        )
    }
}

extension CreateImageState: IsFeedbackState {
    enum Event {
        case onUpdateCurrentUser(UserDetailFragment?)
        case onProgress(RxProgress)
        case onError(Error)
        case onSavedMedium(MediumFragment)
        case triggerSave
        case triggerCancel
    }
}

extension CreateImageState {
    
    static func reduce(state: CreateImageState, event: CreateImageState.Event) -> CreateImageState {
        switch event {
        case .onUpdateCurrentUser(let currentUser):
            return state.mutated {
                $0.currentUser = currentUser
                $0.next.userId = currentUser?.id ?? ""
            }
        case .onProgress(let progress):
            return state.mutated {
                $0.progress = progress
            }
        case .onError(let error):
            return state.mutated {
                $0.error = error
                $0.savedMedium = nil
                $0.triggerSave = false
            }
        case .onSavedMedium(let medium):
            return state.mutated {
                $0.error = nil
                $0.savedMedium = medium
                $0.triggerSave = false
            }
        case .triggerSave:
            guard state.shouldSaveImage else { return state }
            return state.mutated {
                $0.triggerSave = true
            }
        case .triggerCancel:
            return state.mutated {
                $0.triggerCancel = ()
            }
        }
    }
}

