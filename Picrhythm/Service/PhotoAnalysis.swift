//
//  PhotoAnalysis.swift
//  Picrhythm
//
//  Created by 郑天烨 on 2019/12/17.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision

class PhotoAnalysis{
    var res:String = ""
    func analysis(img:UIImage?,pHashValues:[NSString:String]) -> String{
        guard let tmpRes = similarity(img: img!, pHashValues: pHashValues)
            else{
                let semaphore = DispatchSemaphore(value: 0)
                classify(img:img!,sema:semaphore)
                semaphore.wait()
                print("res:\(res)")
                return res
        }
        setTag(str: tmpRes.0)
        print("res:\(res)")
        return res
    }
    private func similarity(img:UIImage,pHashValues:[NSString:String]) -> (String,NSInteger)?{
        let pHashValue = pHashValueWithImage(img: img)
        let str = pHashValue.utf8String!
        var diffs:[NSString:NSInteger] = [:]
        for dic in pHashValues{
            var diff:NSInteger = 0
            let sampleStr = dic.key.utf8String!
            for i in 0..<pHashValue.length {
                if str[i] != sampleStr[i] {
                    diff += 1
                }
            }
            diffs.updateValue(diff, forKey: dic.key)
        }
        var minDiff:NSString = ""
        var minVal:NSInteger = NSInteger.max
        for dic in diffs{
            let val = dic.value
            if val < minVal{
                minDiff = dic.key
                minVal = dic.value
            }
        }
        if minVal < 7{
            return nil
        }
        else{
            return (pHashValues[minDiff]!,minVal)
        }
    }
    func pHashValueWithImage(img: UIImage) -> NSString {
        let scaledImg = scaleToSize(image: img, size: CGSize(width: 20, height: 20))
        let image = getGrayImage(sourceImage: scaledImg)
        let pHashString = NSMutableString()
        let imageRef = image.cgImage!
        let width = imageRef.width
        let height = imageRef.height
        let pixelData = imageRef.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var sum: Int = 0
        for i in 0..<width * height {
            if data[i] != 0 {
                sum = sum + Int(data[i])
            }
        }
        let avr = sum / (width * height)
        for i in 0..<width * height {
            if Int(data[i]) >= avr {
                pHashString.append("1")
            } else {
                pHashString.append("0")
            }
        }
        return pHashString
    }
    private func getGrayImage(sourceImage: UIImage) -> UIImage {
        let imageRef: CGImage = sourceImage.cgImage!
        let width: Int = imageRef.width
        let height: Int = imageRef.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context: CGContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        let rect: CGRect = CGRect.init(x: 0, y: 0, width: width, height: height)
        context.draw(imageRef, in: rect)
        let outPutImage: CGImage = context.makeImage()!
        let newImage: UIImage = UIImage.init(cgImage: outPutImage)
        return newImage
    }
    private func scaleToSize(image:UIImage,size:CGSize) -> UIImage{
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    private func classify(img:UIImage,sema:DispatchSemaphore){
        
        guard let ciImage = CIImage(image: img)
            else{
                fatalError("cannot convert UIImage to CIImage")
        }
        guard let model = try?VNCoreMLModel(for: MobileNetV2().model)
            else{
                fatalError("cannot load ML model")
        }
        let request = VNCoreMLRequest(model: model){
            request,error in
            guard let results = request.results as? [VNClassificationObservation],let topResult = results.first
                else{
                    fatalError("cannot get expected results")
            }
            let subStrings = topResult.identifier.split(separator: ",")
            self.setTag(str:"\(subStrings.first ?? "happy")")
            sema.signal()
        }
        request.imageCropAndScaleOption = .centerCrop
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do{
                try handler.perform([request])
            }catch{
                fatalError("fail to perform classification")
            }
        }
    }
    private func setTag(str:String){
        self.res = str
        print("restmp:\(res)")
    }
    /*func process(for request:VNRequest,error:Error?){
        DispatchQueue.main.async {
            guard let results = request.results as? [VNClassificationObservation],let topResult = results.first
                else{
                    fatalError("cannot get expected results")
            }
        }
    }*/
}
