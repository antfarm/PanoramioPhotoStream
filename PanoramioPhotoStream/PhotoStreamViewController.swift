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


    private var previousPhotoLocation: CLLocation?
    private var distanceBetweenPhotoLocations = Config.Location.distanceBetweenPhotoLocations


    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self

        collectionView.dataSource = self
        collectionView.delegate = self
    }


    @IBAction func startStreaming(sender: UIBarButtonItem) {

        startButtonItem.enabled = false
        stopButtonItem.enabled = true

        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }


    @IBAction func stopStreaming(sender: UIBarButtonItem) {

        stopButtonItem.enabled = false
        startButtonItem.enabled = true

        locationManager.stopUpdatingLocation()
    }
}



extension PhotoStreamViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        for location in locations {

            guard let previousLocation = previousPhotoLocation else {

                previousPhotoLocation = location
                fetchPhotoForLocation(location)
                continue
            }

            let distanceToLastPhotoLocation = location.distanceFromLocation(previousLocation)

            print("Distance: \(distanceToLastPhotoLocation)")

            if distanceToLastPhotoLocation >= self.distanceBetweenPhotoLocations {
                
                previousPhotoLocation = location
                fetchPhotoForLocation(location)
            }
        }
    }
    
    
    func fetchPhotoForLocation(location: CLLocation) {

        print("Fetching photo for coordinate: \(location.coordinate)")

        PanoramioClient().fetchPhotoForLocation(location) { (photo) in

            print("Done fetching photo: \(photo)")

            guard let photo = photo else {

                print("No photo found, decreasing distance.")
                self.distanceBetweenPhotoLocations = Config.Location.shortDistanceBetweenPhotoLocations
                return
            }

            guard !self.photoStream.containsPhotoWithPanoramioID(photo.panoramioID) else {

                print("Photo already exists, decreasing distance.")
                self.distanceBetweenPhotoLocations = Config.Location.shortDistanceBetweenPhotoLocations
                return
            }

            self.distanceBetweenPhotoLocations = Config.Location.distanceBetweenPhotoLocations

            NSOperationQueue.mainQueue().addOperationWithBlock {

                self.photoStream.addPhoto(photo)
                self.collectionView.reloadData()
            }
        }
    }
}



extension PhotoStreamViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        let photo = photoStream[indexPath.row]

        print("Fetching image for photo #\(photo.uuid)")

        if let storedImage = imageStore.imageForKey(photo.uuid) {

            print("Retrieving stored image for photo #\(photo.uuid)")

            if let cell = cellForPhotoWithUUID(photo.uuid) {
                cell.setImage(storedImage)
            }

            return
        }

        print("Downloading image for photo #\(photo.uuid) ...")

        panoramioClient.downloadImageForPhoto(photo) { image in

            print("Done downloading image for photo #\(photo.uuid): \(image)")

            guard let downloadedImage = image else {

                NSOperationQueue.mainQueue().addOperationWithBlock {

                    self.photoStream.removePhotoWithUUID(photo.uuid)
                    self.collectionView.reloadData()
                }

                return
            }

            self.imageStore.setImage(downloadedImage, forKey: photo.uuid)

            NSOperationQueue.mainQueue().addOperationWithBlock {

                if let cell = self.cellForPhotoWithUUID(photo.uuid) {
                    cell.setImage(downloadedImage)
                }
            }
        }
    }


    private func cellForPhotoWithUUID(uuid: String) -> PhotoCollectionViewCell? {

        let index = photoStream.indexOfPhotoWithUUID(uuid)
        let indexPath = NSIndexPath(forRow: index!, inSection: 0)

        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell

        return cell
    }
}



extension PhotoStreamViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCollectionViewCell.reuseId, forIndexPath: indexPath) as! PhotoCollectionViewCell

        let photo = photoStream[indexPath.row]
        let image = imageStore.imageForKey(photo.uuid)

        cell.setImage(image)

        return cell
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return photoStream.count
    }
}



extension PhotoStreamViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let lineSpacing = flowLayout.minimumLineSpacing

        let width = collectionView.bounds.width - 2 * lineSpacing
        let height = width / Config.CollectionView.imageRatio

        return CGSize(width: width, height: height)
    }
}