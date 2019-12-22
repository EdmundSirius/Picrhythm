//
//  DownloadService.swift
//  Picrhythm
//
//  Created by 郑天烨 on 2019/12/7.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import Foundation

class DownloadService {
    
    // 当前活跃的 download ：从 URL 到 Download 对象的映射
    var activeDownloads: [URL: Download] = [ : ]
    // downloadsSession 下载任务
    var downloadsSession: URLSession!
    
    func startDownload(_ track: Track) {
        
      // 根据 Track 对象创建 Download 对象
      let download = Download(track: track)
      // 设置新 download，让任务开始
      download.task = downloadsSession.downloadTask(with: track.previewURL)
      download.task?.resume()
      // isDownloading
      download.isDownloading = true
      // 加入字典
      activeDownloads[download.track.previewURL] = download
    }
}
