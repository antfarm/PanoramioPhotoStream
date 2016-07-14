//
//  PhotoStreamViewController.swift
//  PanoramioPhotoStream
//
//  Created by sean on 09/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
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
    var imageCache: ImageCache!

    private var previousPhotoLocation: CLLocation?
    private var distanceBetweenPhotoLocations: CLLocationDistance = Config.distanceBetweenPhotoLocations


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

//            #if DEBUG
//
//            // Simulating location on the device using a GPX file mixes real sensor readings with
//            // simulated ones for the first few locations, so we ignore the first couple locations ...
//
//            struct Counter { static var count = 0 }
//
//            guard Counter.count > 5 else {
//                Counter.count += 1
//                print("IGNORING LOCATION: \(location.coordinate)")
//                return
//            }
//
//            #endif

            guard let previousLocation = previousPhotoLocation else {

                previousPhotoLocation = location
                showPhotoForLocation(location)

                continue
            }

            let distanceToLastPhotoLocation = location.distanceFromLocation(previousLocation)

            print("Distance: \(distanceToLastPhotoLocation)")

            if distanceToLastPhotoLocation >= self.distanceBetweenPhotoLocations {

                previousPhotoLocation = location
                showPhotoForLocation(location)
            }
        }
    }


    func showPhotoForLocation(location: CLLocation) {

        print("Fetching photo for coordinate: \(location.coordinate)")
        
        PanoramioClient().fetchPhotoForLocation(location) { (photo) in
            
            print("Done fetching photo: \(photo)")

            guard let photo = photo else {
                print("No photo found, decreasing distance.")
                self.distanceBetweenPhotoLocations = Config.shortDistanceBetweenPhotoLocations
                return
            }

            guard !self.photoStream.containsPhotoWithPanoramioID(photo.panoramioID) else {
                print("Photo already exists, decreasing distance.")
                self.distanceBetweenPhotoLocations = Config.shortDistanceBetweenPhotoLocations
                return
            }

            self.distanceBetweenPhotoLocations = Config.distanceBetweenPhotoLocations

            NSOperationQueue.mainQueue().addOperationWithBlock {

                self.photoStream.addPhoto(photo)
                self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])

                // TODO: Downloading the image twice !!!
                //       Without this, cells don't update properly.
                self.collectionView.reloadSections(NSIndexSet(index: 0))
            }
        }
    }
}



extension PhotoStreamViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        let photo = photoStream[indexPath.row]

        print("Fetching image for photo #\(photo.uuid)")

        if let storedImage = imageCache.imageForKey(photo.uuid) {

            print("Retrieving stored image for photo #\(photo.uuid)")

            if let cell = cellForPhotoWithUUID(photo.uuid) {
                cell.image = storedImage
            }

            return
        }

        print("Downloading image for photo #\(photo.uuid) ...")

        panoramioClient.downloadImageForPhoto(photo) { image in

            print("Done downloading image for photo #\(photo.uuid): \(image)")

            guard let downloadedImage = image else {

                // photoStream.removePhotoWithUUID()
                // self.collectionView.reloadSections(NSIndexSet(index: 0))

                if let cell = self.cellForPhotoWithUUID(photo.uuid) {
                    cell.image = nil
                }

                return
            }

            self.imageCache.setImage(downloadedImage, forKey: photo.uuid)

            NSOperationQueue.mainQueue().addOperationWithBlock {

                if let cell = self.cellForPhotoWithUUID(photo.uuid) {
                    cell.image = downloadedImage
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
        let image = imageCache.imageForKey(photo.uuid)

        cell.image = image

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
        let height = width / Config.imageRatio

        return CGSize(width: width, height: height)
    }
}