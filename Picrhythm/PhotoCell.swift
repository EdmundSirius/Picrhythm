//
//  PhotoCell.swift
//  Picrhythm
//
//  Created by apple on 2019/11/28.
//  Copyright © 2019 437.Inc. All rights reserved.
//

import UIKit

class PhotoCell:UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var tagLabel: UILabel!
    
    
    override func awakeFromNib() {
      super.awakeFromNib()
      containerView.layer.cornerRadius = 6
      containerView.layer.masksToBounds = true
    }
    
    var photo: PM? {
      didSet {
        if let photo = photo {
            imageView.image = photo.image
            tagLabel.text = photo.tag
        }
      }
    }
}
