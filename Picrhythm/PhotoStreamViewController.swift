//
//  PhotoStreamViewController.swift
//  Picrhythm
//
//  Created by apple on 2019/11/26.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoStreamViewController:UICollectionViewController{
    var photos = PM.getAllPhotos()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        collectionView?.backgroundColor = .white
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
    }
}

extension PhotoStreamViewController:UICollectionViewDelegateFlowLayout{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
        cell.photo = photos[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
      return CGSize(width: itemSize, height: itemSize)
    }
}

extension PhotoStreamViewController: PinterestLayoutDelegate{
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return photos[indexPath.item].image.size.height
    }
}

extension PhotoStreamViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBAction func getFromAlbum(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: {() -> Void in })
        }
        else{
            print("No Albeum")
        }
    }
    @IBAction func getFromCamera(_ sender: UIButton) {
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*if let url = info[UIImagePickerController.InfoKey.mediaURL]{
            if let path:String = url as? String{
                PM.addNewPhoto(path: path)
            }
            else{
                print("error 1")
            }
        }
        else{
            print("error 2")
        }*/
        if let imgURL = info[UIImagePickerController.InfoKey.imageURL]{
            PM.addNewPhoto(imgURL: imgURL as! URL)
            photos = PM.getAllPhotos()
        }
        else{
            print("failure")
        }
        /*if let img = info[UIImagePickerController.InfoKey.originalImage]{
            //let newPhoto = PM(image: img as! UIImage, tag: "default")
            //photos.append(newPhoto)
            PM.getAllPhotos()
        }
        else{
            print("failure2")
        }*/
        
        picker.dismiss(animated: true, completion: {() -> Void in})
    }
}
