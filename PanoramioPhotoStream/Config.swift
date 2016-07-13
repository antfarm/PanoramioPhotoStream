//
//  Config.swift
//  PanoramioPhotoStream
//
//  Created by sean on 09/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import CoreLocation
import CoreGraphics


struct Config {

    static let imageRatio = CGFloat(16) / 10

    static let requestedImageSize = PanoramioClient.ImageSize.Original

    static let distanceBetweenPhotoLocations = CLLocationDistance(100)
    static let shortDistanceBetweenPhotoLocations = CLLocationDistance(20)

    static let photoLocationMaxOffsetMetres = CLLocationDistance(30)
}