//
//  PhotoStream.swift
//  PanoramioPhotoStream
//

import Foundation


class PhotoStream {

    private var photos = [Photo]()


    private var session: URLSession {
        get {
            return URLSession.shared
        }
    }


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


    func addPhoto(photo: Photo) {

        photos.insert(photo, at: 0)
    }


    func removePhotoWithUUID(uuid: String) {

        if let index = indexOfPhotoWithUUID(uuid: uuid) {
            photos.remove(at: index)
        }
    }


    func photoWithUUID(uuid: String) -> Photo? {

        guard let index = indexOfPhotoWithUUID(uuid: uuid) else {
            return nil
        }

        return photos[index]
    }


    func indexOfPhotoWithUUID(uuid: String) -> Int? {
        
        return photos.index { $0.uuid == uuid }
    }


    func containsPhotoWithPanoramioID(panoramioID: Int) -> Bool {

        let index = photos.index { $0.panoramioID == panoramioID }

        return index != nil
    }
}


