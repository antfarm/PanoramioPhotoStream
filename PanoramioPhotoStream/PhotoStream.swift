//
//  PhotoStream.swift
//  PanoramioPhotoStream
//
//  Created by sean on 11/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import UIKit


class Photo: CustomStringConvertible {

    var id: Int
    var imageURL: NSURL
    var image: UIImage?


    init(id: Int, imageURL: NSURL, image: UIImage?) {
        
        self.id = id
        self.imageURL = imageURL
        self.image  = image
    }


    var description: String {
        get {
            return "Photo (id: \(id), imageURL: \(imageURL), image: \(image)"
        }
    }
}


class PhotoStream {

    var photos = [Photo]()

    private let session: NSURLSession


    init() {

        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
    }


    func fetchImageForPhoto(photo: Photo, completion: (UIImage?) -> ()) {

        print("Fetching: image for photo #\(photo.id)")
        
        if let image = photo.image {

            print ("Loading from cache: image for photo #\(photo.id)")

            completion(image)
            return
        }

        print ("Downloading: image for photo #\(photo.id)")

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


