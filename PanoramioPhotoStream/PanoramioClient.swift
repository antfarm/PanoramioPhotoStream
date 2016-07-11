//
//  PanoramioClient.swift
//  PanoramioPhotoStream
//
//  Created by sean on 09/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


class PanoramioClient { // cf. http://www.panoramio.com/api/data/api.html

    private let session: NSURLSession


    init() {

        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
    }


    func fetchPhotoForLocation(location: CLLocation, completion: (Photo?) -> Void) {

        let url = PanoramioClient.photosURLForLocation(location)
        print("URL: \(url)")

        let request = NSURLRequest(URL: url)
        var photo: Photo?

        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in

            if let data = data {
                photo = self.photoFromJSONData(data)
            }
            else if let requestError = error {
                print("Error: \(requestError)")
                photo = nil
            }
            else {
                print("Error")
                photo = nil
            }

            completion(photo)
        }

        task.resume()
    }


    private func photoFromJSONData(data: NSData) -> Photo? {

        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])

            if  let jsonDict = jsonObject as? [String: AnyObject],
                let count = jsonDict["count"] as? Int where count > 60,
                let photos = jsonDict["photos"] as? [[String: AnyObject]],
                let firstPhoto = photos.first,
                let id = firstPhoto["photo_id"] as? Int,
                let imageURLString = firstPhoto["photo_file_url"] as? String {

                    print(count)

                    let components = NSURLComponents(string: imageURLString)!
                    let imageURL = components.URL!

                    let photo = Photo(id: id, imageURL: imageURL, image: nil)
                
                    return photo
            }
        }
        catch let error {
            print("Error creating JSON object: \(error)")
        }

        return nil
    }


    // MARK: URLs


    private static let baseURLString = "http://www.panoramio.com/map/get_panoramas.php"

    private static let baseParams = [
        
        "from":      "0",
        "to":        "1",
        "set":       "full",
        "size":      "original",
        "mapfilter": "false"
    ]


    private static func photosURLWithParams(parameters: [String: String]) -> NSURL {

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