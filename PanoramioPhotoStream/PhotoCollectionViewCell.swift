//
//  PhotoCollectionViewCell.swift
//  PanoramioPhotoStream
//
//  Created by sean on 09/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import UIKit


class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    static let reuseId = "Photo Collection View Cell"


    var image: UIImage? {

        get {
            return photoImageView.image
        }

        set(image) {

            photoImageView.image = image

            if image == nil {
                activityIndicator.startAnimating()
            }
            else {
                activityIndicator.stopAnimating()
            }
        }
    }

    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        image = nil
//    }


    override func prepareForReuse() {
        super.prepareForReuse()

        image = nil
    }
}