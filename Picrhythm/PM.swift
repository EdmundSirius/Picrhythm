//
//  PM.swift
//  Picrhythm
//
//  Created by apple on 2019/11/28.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import UIKit

struct PM {
    var image:UIImage
    var tag:String
    
    init?(image:UIImage,tag:String){
        self.image = image
        self.tag = tag
    }
    
    static func getAllPhotos() -> [PM] {
        var photos:[PM] = []
        let manager = FileManager.default
        let url = manager.currentDirectoryPath + "/Photos"
        guard let urls = try?manager.contentsOfDirectory(atPath: url)
            else{
                return photos
        }
        for item in urls{
            if let img = UIImage(contentsOfFile: item){
                if let pm = PM(image: img, tag: "default"){
                    photos.append(pm)
                }
            }
        }
        return photos
    }
}
