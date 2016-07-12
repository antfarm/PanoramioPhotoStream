//
//  Config.swift
//  PanoramioPhotoStream
//
//  Created by sean on 09/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import CoreLocation


struct Config {

    static let distanceBetweenPhotoLocations = CLLocationDistance(100)
    static let shortDistanceBetweenPhotoLocations = CLLocationDistance(10)

    // http://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters
    // static let maximumPhotoLatitudeOffset = CLLocationDistance(10)
    // static let maximumPhotoLongitudeOffset = CLLocationDistance(10)
}