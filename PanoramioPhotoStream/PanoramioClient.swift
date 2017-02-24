//
//  PanoramioClient.swift
//  PanoramioPhotoStream
//

import CoreLocation
import UIKit


class PanoramioClient { // cf. http://www.panoramio.com/api/data/api.html

    enum ImageSize: String {

        case Medium = "medium"
        case Original = "original"
    }

    
    private var session: URLSession {
        get {
            return URLSession.shared
        }
    }


    func fetchPhotoForLocation(location: CLLocation, completion: @escaping (Photo?) -> Void) {

        let url = PanoramioClient.photosURLForLocation(location: location)
        let request = URLRequest(url: url)

        let task = session.dataTask(with: request) { (data, response, error) -> Void in

            var photo: Photo? = nil

            if let requestError = error {
                print("Error fetching photo data: \(requestError)")

                completion(photo)
                return
            }

            if let data = data {
                photo = self.photoFromJSONData(data: data)
            }

            completion(photo)
        }

        task.resume()
    }


    private func photoFromJSONData(data: Data) -> Photo? {

        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])

            if  let jsonDict = jsonObject as? [String: AnyObject],
                let count = jsonDict["count"] as? Int, count > 0,
                let photos = jsonDict["photos"] as? [[String: AnyObject]],
                let firstPhoto = photos.first,
                let panoramioId = firstPhoto["photo_id"] as? Int,
                let imageURLString = firstPhoto["photo_file_url"] as? String {

                    let components = URLComponents(string: imageURLString)!
                    let imageURL = components.url!

                    let photo = Photo(panoramioID: panoramioId, imageURL: imageURL, image: nil)
                
                    return photo
            }
        }
        catch let error {
            print("Error creating JSON object: \(error)")
        }

        return nil
    }


    func downloadImageForPhoto(photo: Photo, completion: @escaping (UIImage?) -> ()) {

        let request = URLRequest(url: photo.imageURL)

        let task = session.dataTask(with: request) { (data, response, error) in

            var image: UIImage? = nil

            if let data = data {
                image = UIImage(data: data)
            }

            completion(image)
        }
        
        task.resume()
    }


    // MARK: URLs


    static func photosURLForLocation(location: CLLocation) -> URL {

        /*
           "If your displacements aren't too great (less than a few kilometers) and you're
           not right at the poles, use the quick and dirty estimate that
           111,111 meters (111.111 km) in the y direction is 1 degree (of latitude) and
           111,111 * cos(latitude) meters in the x direction is 1 degree (of longitude)."

           [http://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters]
         */

        let offsetMetres = Config.Panoramio.photoLocationMaxOffsetMetres

        let latitudeOffset = offsetMetres / 111111
        let longitudeOffset = offsetMetres / (111111 * cos(location.coordinate.latitude * M_PI / 180))

        let params = [
            "minx": String(location.coordinate.longitude - longitudeOffset),
            "maxx": String(location.coordinate.longitude + longitudeOffset),
            "miny": String(location.coordinate.latitude - latitudeOffset),
            "maxy": String(location.coordinate.latitude + latitudeOffset)
        ]

        return photosURLWithParams(parameters: params)
    }


    private static let baseURLString = "http://www.panoramio.com/map/get_panoramas.php"

    private static let baseParams = [
        
        "from":      "0",
        "to":        "1",
        "set":       "full",
        "mapfilter": "false",
        "size":      Config.Panoramio.requestedImageSize.rawValue
    ]


    private static func photosURLWithParams(parameters: [String: String]) -> URL {

        var queryItems = [URLQueryItem]()

        for (key, value) in baseParams {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        var components = URLComponents(string: baseURLString)!
        components.queryItems = queryItems

        return components.url!
    }
}
