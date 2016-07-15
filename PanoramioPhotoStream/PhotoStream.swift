//
//  PhotoStream.swift
//  PanoramioPhotoStream
//

import UIKit


class Photo {

    var uuid: String

    var panoramioID: Int
    var imageURL: NSURL


    init(panoramioID: Int, imageURL: NSURL, image: UIImage? = nil) {

        self.uuid = NSUUID().UUIDString

        self.panoramioID = panoramioID
        self.imageURL = imageURL
    }
}


extension Photo: CustomStringConvertible {

    var description: String {
        
        get {
            return "Photo (uuid: \(uuid), panoramioIid: \(panoramioID)"
        }
    }
}


class PhotoStream {

    private var photos = [Photo]()

    private let session: NSURLSession


    var count: Int {
        get {
            return photos.count
        }
    }


    subscript(index: Int) -> Photo {
        get {
            return photos[index]
        }
    }


    init() {

        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
    }


    func addPhoto(photo: Photo) {

        photos.insert(photo, atIndex: 0)
    }


    func removePhotoWithUUID(uuid: String) {

        if let index = indexOfPhotoWithUUID(uuid) {
            photos.removeAtIndex(index)
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
}


