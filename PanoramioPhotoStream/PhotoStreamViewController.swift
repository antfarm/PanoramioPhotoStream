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


    override func didReceiveMemoryWarning() {

        // dispose of cached images
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
            }
        }
    }
}



extension PhotoStreamViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        let photo = photoStream[indexPath.row]

        photoStream.fetchImageForPhoto(photo) { _ in

            print ("Done fetching image for photo #\(photo.uuid): \(photo.image)")

            NSOperationQueue.mainQueue().addOperationWithBlock {

                let index = self.photoStream.indexOfPhotoWithUUID(photo.uuid)
                let indexPath = NSIndexPath(forRow: index!, inSection: 0)

                if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell {
                    cell.image = photo.image
                }
            }
        }
    }
}



extension PhotoStreamViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCollectionViewCell.reuseId, forIndexPath: indexPath) as! PhotoCollectionViewCell

        let photo = photoStream[indexPath.row]
        cell.image = photo.image

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