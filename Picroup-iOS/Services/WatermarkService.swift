//
//  WatermarkService.swift
//  Picroup-iOS
//
//  Created by ovfun on 2018/8/10.
//  Copyright © 2018年 luojie. All rights reserved.
//

import Foundation
import MediaWatermark
import RxSwift

enum WatermarkError: Error {
    case imageDataUnavailable(URL)
    case neverHappen
}

enum MediaItemType {
    case image
    case video
}

extension MediaItem {
    var type: MediaItemType {
        return sourceAsset != nil ? .video : .image
    }
}

struct WatermarkService {
    
    private struct Constants {
        static let colorAlpha: CGFloat = 0.7
        static let watermarkMarginRatio: CGFloat = 0.02
        static let logoFontRatio: CGFloat = 0.05
        static let usernameFontRatio: CGFloat = logoFontRatio * 0.75
    }
    
    static func addImageWatermark(image: UIImage, username: String) -> Single<UIImage> {
        let item = MediaItem(image: image)
        let watermark = warkmarkElement(username: username, for: item)
        item.add(element: watermark)
        return MediaProcessor().rx.processElements(item: item)
            .map {
                guard let image = $0.image else { throw WatermarkError.neverHappen }
                return image
        }
    }
    
    static func addVideoWatermark(videoURL: URL, username: String) -> Single<URL> {
        guard let item = MediaItem(url: videoURL) else {
            return Single.error(WatermarkError.imageDataUnavailable(videoURL))
        }
        let watermark = warkmarkElement(username: username, for: item)
        item.add(element: watermark)
        return MediaProcessor().rx.processElements(item: item)
            .map {
                guard let url = $0.processedUrl else { throw WatermarkError.neverHappen }
                return url
        }
    }
    
    private static func warkmarkElement(username: String, for mediaItem: MediaItem) -> MediaElement {
        let mediumSize = mediaItem.size
        let text = warkmarkText(username: username, mediumSize: mediumSize)
        let watermark = MediaElement(text: text)
        let margin = mediumSize.width * Constants.watermarkMarginRatio
        let y = mediaItem.type == .video ? margin : mediumSize.height - margin - text.size().height
        watermark.frame = CGRect(x: margin, y: y, width: text.size().width, height: text.size().height)
        return watermark
    }
    
    private static func warkmarkText(username: String, mediumSize: CGSize) -> NSAttributedString {
        let mediumWidth = mediumSize.width
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: "Picroup ", attributes: [
            .foregroundColor: UIColor.white.withAlphaComponent(Constants.colorAlpha),
            .font: UIFont(name: "HelveticaNeue-Bold", size: mediumWidth * Constants.logoFontRatio)!,
            ]))
        string.append(NSAttributedString(string: "作者 @\(username)", attributes: [
            .foregroundColor: UIColor.white.withAlphaComponent(Constants.colorAlpha),
            .font: UIFont(name: "HelveticaNeue", size: mediumWidth * Constants.usernameFontRatio)!,
            ]))
        return string
    }
    
}


extension MediaProcessor: ReactiveCompatible {}
extension Reactive where Base: MediaProcessor {
    func processElements(item: MediaItem) -> Single<MediaProcessResult>  {
        let processor = base
        return Single.create { events in
            processor.processElements(item: item) { (result, error) in
                guard error == nil else {
                    events(.error(error!))
                    return
                }
                events(.success(result))
            }
            return Disposables.create()
        }
    }
}
