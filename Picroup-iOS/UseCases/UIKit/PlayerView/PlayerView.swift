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
import DVAssetLoaderDelegate

public final class PlayerView: UIView {
    
    @IBOutlet var contentView: UIView!
    var cacheService: CacheService?
    
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
        
        cacheService = HYDefaultCacheService.shared
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = contentView.bounds
    }
    
    func play(with url: String?) {
        play(url: url?.toURL())
    }
    
    func play(url: URL?) {
        guard let url = url else { return reset() }
        self.url = url
        weak var weakSelf = self
        
        let urlAsset: AVURLAsset
        if let fileURL = cacheService?.fileURL(for: url) {
            print("from cache")
            urlAsset = AVURLAsset(url: fileURL)
        } else {
            print("from server")
            urlAsset = {
                let item = DVURLAsset(url: url)
                item.loaderDelegate = self
                return item
            }()
        }
        let playerItem = AVPlayerItem(asset: urlAsset)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        tokens.append(NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
            weakSelf?.player?.seek(to: kCMTimeZero)
            weakSelf?.player?.play()
        })
        
        tokens.append(NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: .main) { _ in
            weakSelf?.player?.play()
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

extension PlayerView: DVAssetLoaderDelegatesDelegate {
    public func dvAssetLoaderDelegate(_ loaderDelegate: DVAssetLoaderDelegate!, didLoad data: Data!, for url: URL!) {
        guard data != nil, url != nil else {
            return print("DVAssetLoaderDelegatesDelegate data or url is nil")
        }
        print("cache video for", url!)
        cacheService?.set(data, for: url)
    }
}
