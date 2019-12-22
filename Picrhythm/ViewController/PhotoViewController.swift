 //
 //  PhotoStreamViewController.swift
 //  Picrhythm
 //
 //  Created by apple on 2019/11/26.
 //  Copyright © 2019 437.Inc. All rights reserved.
 //

 import UIKit
 import AVFoundation

 class PhotoViewController:UICollectionViewController{
    var photos = [Photo]()
    var pHashValueOfSamplePhotos:[NSString:String] = [:]
     
     override var preferredStatusBarStyle: UIStatusBarStyle{
         return .lightContent
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()
         if let allPhotos = getSavedPhotos(){
             photos += allPhotos
         }
         else{
             getSamplePhotos()
         }
         if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
             layout.delegate = self
         }

         collectionView?.backgroundColor = .white
         collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
     }
     
     private func getSavedPhotos() -> [Photo]?{
         guard let savedPhotoData = FileManager().contents(atPath: Photo.urlOfPhotos.path)
             else{
                 return nil
         }
         do{
             return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPhotoData) as? [Photo]
         }catch{
             return nil
         }
     }
     
     private func getSamplePhotos(){
        guard let url = Bundle.main.url(forResource: "Samples", withExtension: "plist"),
            let samples = NSArray(contentsOf: url) as? [[String:String]]
            else{
                return
        }
        for sample in samples{
            guard let image = sample["image"],
            let tag = sample["tag"],
            let uiimage = UIImage(named: image),
            let photo = Photo(image: uiimage, tag: tag)
                else{
                    fatalError("cannot get sample photo")
            }
            let pHashValueOfSample:NSString = PhotoAnalysis().pHashValueWithImage(img: uiimage)
            pHashValueOfSamplePhotos.updateValue(tag, forKey: pHashValueOfSample)
            photos.append(photo)
        }
        do{
            let samplePhotoData = try NSKeyedArchiver.archivedData(withRootObject: photos, requiringSecureCoding: true)
                try samplePhotoData.write(to: Photo.urlOfPhotos)
            }catch{}
     }
     
     private func savePhotos(){
         do{
             let toSavedPhotoData = try NSKeyedArchiver.archivedData(withRootObject: photos, requiringSecureCoding: true)
             try toSavedPhotoData.write(to: Photo.urlOfPhotos)
         }catch{}
     }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "GoToPlayer"{
            guard let PlayerViewController = segue.destination as? PlayerViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPhotoCell = sender as? PhotoCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = collectionView.indexPath(for: selectedPhotoCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPhoto = photos[indexPath.row]
            PlayerViewController.photo = selectedPhoto
        }
        else{
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
   
    
 }
    
 extension PhotoViewController:UICollectionViewDelegateFlowLayout{
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

 extension PhotoViewController: PinterestLayoutDelegate{
     func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
         return photos[indexPath.item].image!.size.height
     }
 }

 extension PhotoViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBAction func getFromAlbum(_ sender: Any) {
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
       @IBAction func getFromCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = false
            self.present(picker,animated: true,completion: {() -> Void in})
        }
            else{
                print("No Camera")
            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {() -> Void in})
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         guard let img = info[.originalImage] as? UIImage
             else{
                 fatalError("cannot get this picture")
         }
         if let newPhoto = Photo(image: img,pHashValues: pHashValueOfSamplePhotos){
             photos.insert(newPhoto, at: 0)
         }
         savePhotos()
         collectionView.reloadData()
         picker.dismiss(animated: true, completion: {() -> Void in})
     }
 }

