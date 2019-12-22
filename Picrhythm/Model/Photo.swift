//
//  PM.swift
//  Picrhythm
//
//  Created by apple on 2019/11/28.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import UIKit
import CoreML
import Vision

class Photo:NSObject,NSCoding {
    
    var image:UIImage?
    var tag:String
    
    static let urlOfDocument = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let urlOfPhotos = urlOfDocument.appendingPathComponent("Photos")
    
    init?(image:UIImage?,tag:String){
        self.image = image
        self.tag = tag
    }
    init?(image:UIImage?,pHashValues:[NSString:String]){
        self.image = image
        self.tag = PhotoAnalysis().analysis(img:image,pHashValues: pHashValues)
    }
    //init?(photo:Photo){
    //    PhotoAnalysis().analysis(photo: photo)
    //    self.image = photo.image
    //   self.tag = photo.tag
    //}
    /*convenience init?(image:UIImage?){
        guard let newImage = image
            else{
                fatalError("cannot get the image")
        }
        
    }*/
    
    func encode(with coder: NSCoder) {
        coder.encode(image, forKey: "image")
        coder.encode(tag,forKey: "tag")
    }
    
    required convenience init?(coder: NSCoder) {
        let image = coder.decodeObject(forKey: "image") as? UIImage
        guard let tag = coder.decodeObject(forKey: "tag") as? String
            else{
                return nil
        }
        self.init(image:image,tag:tag)
    }
    
    /*func getTag(){
        PhotoAnalysis().analysis(photo: self)
        print("tag:\(tag)")
    }*/
}



