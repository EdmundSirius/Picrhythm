//
//  PlayerService.swift
//  Picrhythm
//
//  Created by 郑天烨 on 2019/12/8.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import UIKit
import AVKit
import Foundation
import MediaPlayer

class PlayerService {
    
    // 当前音乐文件路径
    var currentMusicFilePath: URL? = nil
    // 当前音乐在搜索结果中的下标
    var currentIndex = 0
    // 是否正在播放
    var isPlaying: Bool = false
    
    // 播放组件
    var asset: AVAsset? = nil
    var playerItem: AVPlayerItem? = nil
    var player: AVPlayer? = nil
    var playerLayer: AVPlayerLayer? = nil
    // 对界面进度条的引用
    var songProcess: UIProgressView!
    
    // 开始播放音乐
    func playMusic() {
        guard player != nil else {
            return
        }
        player?.play()
    }
    
    // 暂停音乐
    func pauseMusic() {
        guard player != nil else {
            return
        }
        player?.pause()
    }
    
    // 开启静音
    func onMute() {
        guard player != nil else {
            return
        }
        player?.isMuted = true
    }
    
    // 关闭静音
    func offMute() {
        guard player != nil else {
            return
        }
        player?.isMuted = false
    }
    
    // 快退
    func rewindMusic(by seconds: Float64) {
        guard player != nil else {
            return
        }
        if let currentTime = player?.currentTime() {
            var newTime = CMTimeGetSeconds(currentTime) - seconds
            if newTime <= 0 {
                newTime = 0
            }
            player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }

    // 快进
    func forwardMusic(by seconds: Float64) {
        guard player != nil else {
            return
        }
        if let currentTime = player?.currentTime(), let duration = player?.currentItem?.duration {
            var newTime = CMTimeGetSeconds(currentTime) + seconds
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    // 初始化音乐播放器
    func initPlayer(videoView: UIView!, progressView: UIProgressView!) {
        if let currentMusicFilePath = currentMusicFilePath {
            //let playerViewController = AVPlayerViewController()
            //present(playerViewController, animated: true, completion: nil)
            //let player = AVPlayer(url: currentMusicFilePath)
            //playerViewController.player = player
            //player.play()
            self.asset = AVAsset(url: currentMusicFilePath)
            self.playerItem = AVPlayerItem(asset: asset!)
            self.player = AVPlayer(playerItem: playerItem)
            
            self.playerLayer = AVPlayerLayer(player: player)
            playerLayer!.frame = videoView.bounds
            playerLayer!.videoGravity = .resizeAspect
            videoView.layer.addSublayer(playerLayer!)
            //player.play()
            
            // 添加进度条时间监视器
            self.player!.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
                if let duration = self?.player!.currentItem?.duration {
                    
                    let durationSeconds = CMTimeGetSeconds(duration)
                    let seconds = CMTimeGetSeconds(progressTime)
                    let progress = Float(seconds/durationSeconds)
                    
                    DispatchQueue.main.async {
                        progressView.progress = progress
                        //self?.progressBar.progress = progress
                        if progress >= 1.0 {
                            progressView.progress = 0.0
                            //self?.progressBar.progress = 0.0
                        }
                    }
                }
            }
            if self.songProcess == nil {
                self.songProcess = progressView
            }
            
        } else {
            print("currentMusicFilePath 为空")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // 设置当前音乐播放路径
    func setCurrentMusicFilePath(currentMusicFilePath: URL) {
        self.currentMusicFilePath = currentMusicFilePath
    }
    
    // 播放完成后
    @objc func playerDidFinishPlaying(note: NSNotification) {
        // print("Video Finished")
        player?.seek(to: CMTime.zero)
        player?.play()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
