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
import Kingfisher

enum CacheError: Swift.Error {
    case imageNotCached
}

struct MediumService {
    
    enum SaveMediumResult {
        case progress(RxProgress)
        case completed(MediumFragment)
    }
    
    static func saveMedium(client: ApolloClient, userId: String, imageKey: String, tags: [String]?) -> Observable<MediumService.SaveMediumResult> {
        guard let pickedImage = ImageCache.default.retrieveImage(forKey: imageKey) else {
            return .error(CacheError.imageNotCached)
        }
        let placeholderColor = pickedImage.averageColor?.hexString
        let (progress, filename) = UpoaderService.uploadImage(pickedImage)
        let rxProgress = progress.map(SaveMediumResult.progress)
        let rxCompleted: Maybe<MediumService.SaveMediumResult> = {
            let (width, aspectRatio) = (pickedImage.size.width, pickedImage.size.aspectRatio)
            let mutation = SaveImageMediumMutation(userId: userId, minioId: filename, width: Double(width), aspectRatio: Double(aspectRatio), placeholderColor: placeholderColor, tags: tags)
            return client.rx.perform(mutation: mutation).map { $0?.data?.saveImageMedium.fragments.mediumFragment }.unwrap()
                .map(SaveMediumResult.completed)
        }()
        return rxProgress.concat(rxCompleted)
    }
    
    static func saveVideo(client: ApolloClient, userId: String, thumbnailImageKey: String, videoFileURL: URL, tags: [String]?) -> Observable<MediumService.SaveMediumResult> {
        guard let thumbnailImage = ImageCache.default.retrieveImage(forKey: thumbnailImageKey) else {
            return .error(CacheError.imageNotCached)
        }
        let placeholderColor = thumbnailImage.averageColor?.hexString
        let (thumbnailProgress, thumbnailMinioId) = UpoaderService.uploadImage(thumbnailImage)
        let (videoProgress, videoMinioId) = UpoaderService.uploadVideo(with: videoFileURL)
        
        let rxProgress: Observable<SaveMediumResult> = {
            let rxThumbnailCompleted = thumbnailProgress.map { $0.completed * 0.2 }
            let rxVideoCompleted = videoProgress.map { $0.completed * 0.8 + 0.2 }
            return rxThumbnailCompleted.concat(rxVideoCompleted)
                .map { .progress(RxProgress(bytesWritten: Int64($0 * 100), totalBytes: 100)) }
        }()

        let rxCompleted: Maybe<MediumService.SaveMediumResult> = {
            let (width, aspectRatio) = (thumbnailImage.size.width, thumbnailImage.size.aspectRatio)
            let mutation = SaveVideoMediumMutation(userId: userId, thumbnailMinioId: thumbnailMinioId, videoMinioId: videoMinioId, width: Double(width), aspectRatio: Double(aspectRatio), placeholderColor: placeholderColor, tags: tags)
            return client.rx.perform(mutation: mutation).map { $0?.data?.saveVideoMedium.fragments.mediumFragment }.unwrap()
                .map(SaveMediumResult.completed)
        }()
        
        return rxProgress.concat(rxCompleted)
    }
}

extension CGSize {
    var aspectRatio: CGFloat {
        return width / height
    }
}
