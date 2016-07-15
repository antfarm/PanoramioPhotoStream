//
//  Photo.swift
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
