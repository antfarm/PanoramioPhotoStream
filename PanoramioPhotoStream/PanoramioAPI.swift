//
//  PanoramioAPI.swift
//  PanoramioPhotoStream
//
//  Created by sean on 09/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import Foundation
import CoreLocation


// http://www.panoramio.com/api/data/api.html

class PanoramioAPI {

    private static let baseURLString = "http://www.panoramio.com/map/get_panoramas.php"

    private static let baseParams = [
        "from":      "0",
        "to":        "1",
        "set":       "full",
        "size":      "original",
        "mapfilter": "false"
    ]

    
    private static func photosURLWithParams(parameters: [String:String]) -> NSURL {

        var queryItems = [NSURLQueryItem]()

        for (key, value) in baseParams {
            queryItems.append(NSURLQueryItem(name: key, value: value))
        }

        for (key, value) in parameters {
            queryItems.append(NSURLQueryItem(name: key, value: value))
        }

        let components = NSURLComponents(string: baseURLString)!
        components.queryItems = queryItems
        
        return components.URL!
    }


    static func photosURLForLocation(location: CLLocation) -> NSURL {

        let offsetLongitude = CLLocationDegrees(0.001427437) / 2
        let offsetLatitude = CLLocationDegrees(0.00089832) / 2
        
        let params = [
            "minx": String(location.coordinate.longitude - offsetLongitude),
            "miny": String(location.coordinate.latitude - offsetLatitude),
            "maxx": String(location.coordinate.longitude + offsetLongitude),
            "maxy": String(location.coordinate.latitude + offsetLatitude)
        ]

        return photosURLWithParams(params)
    }
}



class PanoramioAPIClient {

    private let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())


    func fetchPhotoForLocation(location: CLLocation) {

        let url = PanoramioAPI.photosURLForLocation(location)
        print("URL: \(url)")

        let request = NSURLRequest(URL: url)

        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in

            if let jsonData = data {

                if let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
                    print(jsonString)
                }
            }
            else if let requestError = error {
                print("Error fetching recent photos: \(requestError)")
            }
            else {
                print("Unexpected error with the request")
            }
        }

        task.resume()
    }
}