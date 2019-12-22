//
//  Download.swift
//  Picrhythm
//
//  Created by 郑天烨 on 2019/12/7.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import Foundation
class Download {
    
  var isDownloading = false          // 是否正在下载
  var progress: Float = 0            // 下载进度
  var resumeData: Data?              // 临时数据
  var task: URLSessionDownloadTask?  // URLSessionDownloadTask
  var track: Track                   // 一个 Download 对象包含唯一 Track 对象
  
  init(track: Track) {
    self.track = track
  }
}
