//
//  PhotoStream.swift
//  PanoramioPhotoStream
//
//  Created by sean on 11/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import UIKit

struct Photo {

    var id: Int
    var imageUrl: String
    var image: UIImage?
}


class PhotoStream {

    var photos = [Photo]()

    func fetchImageForPhoto(photo: Photo, completion: (UIImage?) -> ()) {

        if let image = photo.image {
            print ("Already have image for photo #\(photo.id) ...")
            completion(image)
            return
        }

        print ("Downloading image for photo #\(photo.id) ...")

        let image = UIImage(named:"gt40_rhinluch.jpg")!
        
        completion(image)
    }

}