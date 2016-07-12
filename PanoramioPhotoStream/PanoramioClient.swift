//
//  PanoramioClient.swift
//  PanoramioPhotoStream
//
//  Created by sean on 09/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//


import CoreLocation


class PanoramioClient { // cf. http://www.panoramio.com/api/data/api.html

    private let session: NSURLSession


    init() {

        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
    }


    func fetchPhotoForLocation(location: CLLocation, completion: (Photo?) -> Void) {

        print("Fetching photo for location: \(location)")

        let url = PanoramioClient.photosURLForLocation(location)

        let request = NSURLRequest(URL: url)

        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in

            var photo: Photo?

            if let requestError = error {
                print("Error fetching photo data: \(requestError)")

                photo = nil
                completion(photo)
                return
            }

            if let data = data {
                photo = self.photoFromJSONData(data)
            }
            else {
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
                let count = jsonDict["count"] as? Int where count > 0,
                let photos = jsonDict["photos"] as? [[String: AnyObject]],
                let firstPhoto = photos.first,
                let panoramioId = firstPhoto["photo_id"] as? Int,
                let imageURLString = firstPhoto["photo_file_url"] as? String {

                    let components = NSURLComponents(string: imageURLString)!
                    let imageURL = components.URL!

                    let photo = Photo(panoramioID: panoramioId, imageURL: imageURL, image: nil)
                
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

        /*
            "If your displacements aren't too great (less than a few kilometers) and you're
             not right at the poles, use the quick and dirty estimate that
             111,111 meters (111.111 km) in the y direction is 1 degree (of latitude) and
             111,111 * cos(latitude) meters in the x direction is 1 degree (of longitude)."
         
            [http://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters]
        */

        let offsetMetres = Config.photoLocationMaxOffsetMetres

        let latitudeOffset = offsetMetres / 111111
        let longitudeOffset = offsetMetres / (111111 * cos(location.coordinate.latitude * M_PI / 180))

        let params = [
            "minx": String(location.coordinate.longitude - longitudeOffset),
            "maxx": String(location.coordinate.longitude + longitudeOffset),
            "miny": String(location.coordinate.latitude - latitudeOffset),
            "maxy": String(location.coordinate.latitude + latitudeOffset)
        ]

        return photosURLWithParams(params)
    }
}