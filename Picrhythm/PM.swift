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
        guard let url = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
            let imagesInPlist = NSArray(contentsOf: url) as? [String]
            else{
                print("empty")
                return photos
        }
        for element in imagesInPlist{
            if let img = UIImage(named: element){
                if let pm = PM(image: img, tag: "default"){
                    photos.append(pm)
                }
            }
        }
        return photos
    }
}
