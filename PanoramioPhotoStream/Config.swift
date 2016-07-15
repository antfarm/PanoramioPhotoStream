//
//  Config.swift
//  PanoramioPhotoStream
//

import CoreLocation
import CoreGraphics


struct Config {

    struct Location {
        static let distanceBetweenPhotoLocations = CLLocationDistance(100)
        static let shortDistanceBetweenPhotoLocations = CLLocationDistance(20)
    }

    struct CollectionView {
        static let imageRatio = CGFloat(16) / 10
    }

    struct Panoramio {
        static let requestedImageSize = PanoramioClient.ImageSize.Medium
        static let photoLocationMaxOffsetMetres = CLLocationDistance(30)
    }

    struct ImageStore {
        static let imagesDirName = "images"
        static let jpegCompressionQuality = CGFloat(0.5)
    }
}