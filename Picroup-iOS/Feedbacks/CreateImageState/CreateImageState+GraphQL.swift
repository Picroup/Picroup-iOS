//
//  graphql.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/22.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Apollo

extension DriverFeedback where State == CreateImageState {
    
    static func saveMedium(client: ApolloClient) -> Raw {
        return react(query: { $0.query }) { (query) in
            return MediumService.saveMedium(client: client, userId: query.userId, pickedImage: query.pickedImage, category: query.selectedCategory)
                .map { result in
                    switch result {
                    case .progress(let progress):
                        return CreateImageState.Event.onProgress(progress)
                    case .completed(let medium):
                        return CreateImageState.Event.onSavedMedium(medium)
                    }
                }.asSignal(onErrorReturnJust: CreateImageState.Event.onError)
        }
    }
}

