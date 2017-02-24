//
//  PhotoCollectionViewCell.swift
//  PanoramioPhotoStream
//

import UIKit


class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    static let reuseId = "Photo Collection View Cell"


    func setImage(image: UIImage?) {

        photoImageView.image = image

        if image == nil {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()

        setImage(image: nil)
    }


    override func prepareForReuse() {
        super.prepareForReuse()

        setImage(image: nil)
    }
}
