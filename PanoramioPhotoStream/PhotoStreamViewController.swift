//
//  PhotoStreamViewController.swift
//  PanoramioPhotoStream
//

import UIKit
import CoreLocation


class PhotoStreamViewController: UIViewController {

    @IBOutlet var startButtonItem: UIBarButtonItem!
    @IBOutlet var stopButtonItem: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!

    var locationManager: CLLocationManager!
    var panoramioClient: PanoramioClient!
    var photoStream: PhotoStream!
    var imageStore: ImageStore!


    fileprivate var previousPhotoLocation: CLLocation?
    fileprivate var distanceBetweenPhotoLocations = Config.Location.distanceBetweenPhotoLocations


    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self

        collectionView.dataSource = self
        collectionView.delegate = self
    }


    @IBAction func startStreaming(_ sender: UIBarButtonItem) {

        startButtonItem.isEnabled = false
        stopButtonItem.isEnabled = true

        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }


    @IBAction func stopStreaming(_ sender: UIBarButtonItem) {

        stopButtonItem.isEnabled = false
        startButtonItem.isEnabled = true

        locationManager.stopUpdatingLocation()
    }
}



extension PhotoStreamViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        for location in locations {

            guard let previousLocation = previousPhotoLocation else {

                previousPhotoLocation = location
                fetchPhotoForLocation(location: location)
                continue
            }

            let distanceToLastPhotoLocation = location.distance(from: previousLocation)

            print("Distance: \(distanceToLastPhotoLocation)")

            if distanceToLastPhotoLocation >= self.distanceBetweenPhotoLocations {
                
                previousPhotoLocation = location
                fetchPhotoForLocation(location: location)
            }
        }
    }
    
    
    func fetchPhotoForLocation(location: CLLocation) {

        print("Fetching photo for coordinate: \(location.coordinate)")

        PanoramioClient().fetchPhotoForLocation(location: location) { (photo) in

            print("Done fetching photo: \(photo)")

            guard let photo = photo else {
                // TODO: New request with larger area around location.

                print("No photo found, decreasing distance.")

                self.distanceBetweenPhotoLocations = Config.Location.shortDistanceBetweenPhotoLocations
                return
            }

            guard !self.photoStream.containsPhotoWithPanoramioID(panoramioID: photo.panoramioID) else {
                // TODO: Always request multiple photos. Try next photo for location.

                print("Photo already exists, decreasing distance.")

                self.distanceBetweenPhotoLocations = Config.Location.shortDistanceBetweenPhotoLocations
                return
            }

            self.distanceBetweenPhotoLocations = Config.Location.distanceBetweenPhotoLocations

            OperationQueue.main.addOperation {

                self.photoStream.addPhoto(photo: photo)
                self.collectionView.reloadData()
            }
        }
    }
}



extension PhotoStreamViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let photo = photoStream[indexPath.row]

        print("Fetching image for photo #\(photo.uuid)")

        if let storedImage = imageStore.imageForKey(key: photo.uuid) {

            print("Retrieving stored image for photo #\(photo.uuid)")

            if let cell = cellForPhotoWithUUID(uuid: photo.uuid) {
                cell.setImage(image: storedImage)
            }

            return
        }

        print("Downloading image for photo #\(photo.uuid) ...")

        panoramioClient.downloadImageForPhoto(photo: photo) { image in

            print("Done downloading image for photo #\(photo.uuid): \(image)")

            guard let downloadedImage = image else {

                OperationQueue.main.addOperation {

                    self.photoStream.removePhotoWithUUID(uuid: photo.uuid)
                    self.collectionView.reloadData()
                }

                return
            }

            self.imageStore.setImage(image: downloadedImage, forKey: photo.uuid)

            OperationQueue.main.addOperation {

                if let cell = self.cellForPhotoWithUUID(uuid: photo.uuid) {
                    cell.setImage(image: downloadedImage)
                }
            }
        }
    }


    private func cellForPhotoWithUUID(uuid: String) -> PhotoCollectionViewCell? {

        let index = photoStream.indexOfPhotoWithUUID(uuid: uuid)
        let indexPath = IndexPath(row: index!, section: 0)

        let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell

        return cell
    }
}



extension PhotoStreamViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseId, for: indexPath) as! PhotoCollectionViewCell

        let photo = photoStream[indexPath.row]
        let image = imageStore.imageForKey(key: photo.uuid)

        cell.setImage(image: image)

        return cell
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return photoStream.count
    }
}



extension PhotoStreamViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let lineSpacing = flowLayout.minimumLineSpacing

        let width = collectionView.bounds.width - 2 * lineSpacing
        let height = width / Config.CollectionView.imageRatio

        return CGSize(width: width, height: height)
    }
}
