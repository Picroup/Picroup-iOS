//
//  MediumService.swift
//  Picroup-iOS
//
//  Created by luojie on 2018/4/11.
//  Copyright © 2018年 luojie. All rights reserved.
//

import RxSwift
import RxCocoa
import RxAlamofire
import Apollo

struct MediumService {
    
    enum SaveMediumResult {
        case progress(RxProgress)
        case completed(MediumFragment)
    }
    
    static func saveMedium(client: ApolloClient, userId: String, pickedImage: UIImage) -> Observable<MediumService.SaveMediumResult> {

        let (progress, filename) = ImageUpoader.uploadImage(pickedImage)
        let rxProgress = progress.map(SaveMediumResult.progress)
        
        let (width, aspectRatio) = (pickedImage.size.width, pickedImage.size.aspectRatio)
        let mutation = SaveImageMediumMutation(userId: userId, minioId: filename, width: Double(width), aspectRatio: Double(aspectRatio))
        let rxCompleted = client.rx.perform(mutation: mutation).map { $0?.data?.saveImageMedium.fragments.mediumFragment }.unwrap()
            .map(SaveMediumResult.completed)
            
        return rxProgress.concat(rxCompleted)
    }
}

extension CGSize {
    var aspectRatio: CGFloat {
        return width / height
    }
}
