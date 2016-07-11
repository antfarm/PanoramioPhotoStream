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
    var imageURL: NSURL
    var image: UIImage?
}


class PhotoStream {

    var photos = [Photo]()

    private let session: NSURLSession


    init() {

        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
    }


    func fetchImageForPhoto(photo: Photo, completion: (UIImage?) -> ()) {

        if let image = photo.image {
            print ("Already have image for photo #\(photo.id) ...")

            completion(image)
            return
        }

        print ("Downloading image for photo #\(photo.id) ...")

        let request = NSURLRequest(URL: photo.imageURL)

        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            var image: UIImage? = nil

            if let data = data {
                image = UIImage(data: data)
            }

            completion(image)
        }

        task.resume()
    }

}


