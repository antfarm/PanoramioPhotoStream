//
//  PhotoStream.swift
//  PanoramioPhotoStream
//
//  Created by sean on 11/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import UIKit


class Photo: CustomStringConvertible {

    var uuid: String

    var panoramioID: Int
    var imageURL: NSURL
    var image: UIImage?


    init(panoramioID: Int, imageURL: NSURL, image: UIImage? = nil) {

        self.uuid = NSUUID().UUIDString

        self.panoramioID = panoramioID
        self.imageURL = imageURL
        self.image  = image
    }


    var description: String {
        
        get {
            return "Photo (uuid: \(uuid), panoramioIid: \(panoramioID), imageURL: \(imageURL), image: \(image)"
        }
    }
}


class PhotoStream {

    private var photos = [Photo]()

    private let session: NSURLSession


    init() {

        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
    }


    func addPhoto(photo: Photo) {

        photos.insert(photo, atIndex: 0)
    }


    subscript(index: Int) -> Photo {

        get {
            return photos[index]
        }
    }


    var count: Int {

        get {
            return photos.count
        }
    }


    func photoWithUUID(uuid: String) -> Photo? {

        guard let index = indexOfPhotoWithUUID(uuid) else {
            return nil
        }

        return photos[index]
    }


    func indexOfPhotoWithUUID(uuid: String) -> Int? {
        
        return photos.indexOf { $0.uuid == uuid }
    }


    func containsPhotoWithPanoramioID(panoramioID: Int) -> Bool {

        let index = photos.indexOf { $0.panoramioID == panoramioID }

        return index != nil
    }


    func fetchImageForPhoto(photo: Photo, completion: (UIImage?) -> ()) {

        print("Fetching: image for photo #\(photo.uuid)")
        
        if let image = photo.image {

            print ("Loading image from cache for photo #\(photo.uuid)")

            completion(image)
            return
        }

        print ("Downloading image for photo #\(photo.uuid)")

        let request = NSURLRequest(URL: photo.imageURL)

        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            if let data = data {
                photo.image = UIImage(data: data)
            }

            completion(photo.image)
        }

        task.resume()
    }
}


