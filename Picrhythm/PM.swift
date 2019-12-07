//
//  PM.swift
//  Picrhythm
//
//  Created by apple on 2019/11/28.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import UIKit

class PM {
    var image:UIImage
    var tag:String
    
    init(image:UIImage,tag:String){
        self.image = image
        self.tag = tag
    }
    
    init?(dic:[String:String]){
        guard let photo = dic["photo"],let tag = dic["tag"],let img = UIImage(named: photo)
            else{
                return nil
        }
        self.image = img
        self.tag = tag
    }
    
    static func addNewPhoto(imgURL: URL){
        guard let url = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
            var list = NSArray(contentsOf: url) as? [[String:String]]
            else{
                return
        }
        let diction:[String:String] = ["photo":imgURL.path,"tag":"default"]
        list.append(diction)
        do{
            try NSArray(array: list).write(to: url)
        }catch{
            print("add fails")
        }
    }
    
    static func getAllPhotos(){
        
    }
    
    static func getExamplePhotos(){
        /*var photos:[PM] = []
        guard let url = Bundle.main.url(forResource: "Examples", withExtension: "plist"),
            let imagesInPlist = NSArray(contentsOf: url) as? [[String:String]]
            else{
                return photos
        }
        for element in imagesInPlist{
            if let pm = PM(dic:element){
                photos.append(pm)
            }
        }*/
        guard let url = Bundle.main.url(forResource: "Examples", withExtension: "plist"),
            let imagesInPlist = NSArray(contentsOf: url) as? [[String:String]]
            else{
                return
        }
        for element in imagesInPlist{
            guard let photo = element["photo"],
            let img = UIImage(named: photo)
                else{
                    return
            }
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        //return photos
    }
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
           if error != nil{
               print("failure")
           }else{
               print("success")
           }
       }
}
