//
//  Track.swift
//  Picrhythm
//
//  Created by 郑天烨 on 2019/11/22.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import Foundation.NSURL
import Foundation

// Query 的结果对象
class Track {
    
    // 歌曲信息及可下载 URL
    let artist: String
    let index: Int
    let name: String
    let previewURL: URL
    
    // 下载后的目标文件URL，没下载则为nil
    var destinationURL: URL? = nil
    
    // 是否已下载
    var downloaded = false
    
    init(name: String, artist: String, previewURL: URL, index: Int) {
      self.name = name
      self.artist = artist
      self.previewURL = previewURL
      self.index = index
    }
}
