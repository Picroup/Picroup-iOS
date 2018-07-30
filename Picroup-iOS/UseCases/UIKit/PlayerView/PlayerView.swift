//
//  PlayerView.swift
//  Test
//
//  Created by luojie on 2018/7/18.
//  Copyright © 2018年 LuoJie. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

public final class PlayerView: UIView {
    
    @IBOutlet var contentView: UIView!
    fileprivate var player: AVPlayer!
    fileprivate var playerLayer: AVPlayerLayer!
    
    fileprivate var url: URL?
    fileprivate var tokens: [NSObjectProtocol] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("\(PlayerView.self)", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        player = AVPlayer(playerItem: nil)
        player.isMuted = true
        player.automaticallyWaitsToMinimizeStalling = false
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        contentView.layer.addSublayer(playerLayer)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = contentView.bounds
    }
    
    func play(with minioId: String?) {
        let url = URLHelper.url(from: minioId)
        play(url: url)
    }
    
    func play(url: URL?) {
        guard let url = url else { return reset() }
        self.url = url
        weak var weakSelf = self

        Cacher.storage?.async.entry(ofType: Data.self, forKey: url.cacheKey, completion: { result in
            guard self.url == url else { return }
            let playerItem: CachingPlayerItem
            if case .value(let entry) = result, let mimeType = url.pathExtension.mimeType {
                print("from cache")
                playerItem = CachingPlayerItem(data: entry.object, mimeType: mimeType, fileExtension: url.pathExtension)
            } else {
                print("from server")
                playerItem = CachingPlayerItem(url: url)
            }
            playerItem.delegate = self
            weakSelf?.player.replaceCurrentItem(with: playerItem)
            weakSelf?.player.play()
            
            weakSelf?.tokens.append(NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
                weakSelf?.player?.seek(to: kCMTimeZero)
                weakSelf?.player?.play()
            })
            
            weakSelf?.tokens.append(NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: .main) { _ in
                weakSelf?.player?.play()
            })
        })
    }
    
    func reset() {
        self.url = nil
        player.pause()
        player.replaceCurrentItem(with: nil)
        removeObservers()
    }
    
    func removeObservers() {
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
        tokens.removeAll()
    }
    
    deinit {
        removeObservers()
    }
    
}

extension PlayerView: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        // A track is downloaded. Saving it to the cache asynchronously.
        print("cache video", playerItem.url)
        Cacher.storage?.async.setObject(data, forKey: playerItem.url.cacheKey, completion: { _ in })
    }
}
