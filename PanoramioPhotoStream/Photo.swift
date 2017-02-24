//
//  Photo.swift
//  PanoramioPhotoStream
//


import UIKit


class Photo {

    var uuid: String

    var panoramioID: Int
    var imageURL: URL


    init(panoramioID: Int, imageURL: URL, image: UIImage? = nil) {

        self.uuid = UUID().uuidString

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
