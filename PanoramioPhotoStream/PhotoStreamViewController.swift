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

        collectionView.dataSource = self
        collectionView.delegate = self
    }


    @IBAction func startStreaming(sender: UIBarButtonItem) {

        startButtonItem.enabled = false
        stopButtonItem.enabled = true

        print("Starting ...")

        locationManager.startUpdatingLocation()
    }


    @IBAction func stopStreaming(sender: UIBarButtonItem) {

        stopButtonItem.enabled = false
        startButtonItem.enabled = true

        print("Stopping ...")

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

        PanoramioClient().fetchPhotoForLocation(location) { (photo) in
            
            print("Photo: \(photo)")

            if let photo = photo {

                self.distanceBetweenPhotoLocations = Config.distanceBetweenPhotoLocations

                NSOperationQueue.mainQueue().addOperationWithBlock {

                    self.photoStream.photos.insert(photo, atIndex: 0)

                    self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
                    //self.collectionView.reloadData()
                    //self.collectionView.reloadSections(NSIndexSet(index: 0))
                }
            }
            else {
                self.distanceBetweenPhotoLocations = Config.shortDistanceBetweenPhotoLocations
            }
        }
    }
}


extension PhotoStreamViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        let photo = photoStream.photos[indexPath.row]

        print("Fetching image for photo #\(photo.id)")

        photoStream.fetchImageForPhoto(photo) { image in

            photo.image = image

            print ("Done fetching image for photo #\(photo.id): \(image)")

            NSOperationQueue.mainQueue().addOperationWithBlock {

                let index = self.photoStream.photos.indexOf { $0.id == photo.id }
                let indexPath = NSIndexPath(forRow: index!, inSection: 0)

                if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell {

                    print("Setting image: \(photo.image)")
                    cell.image = photo.image
                    cell.backgroundColor = UIColor.redColor()
                }
                else {
                    print("No cell with index \(indexPath)")
                }
            }
        }
    }
}


extension PhotoStreamViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCollectionViewCell.reuseId, forIndexPath: indexPath) as! PhotoCollectionViewCell

        cell.image = photoStream.photos[indexPath.row].image

        return cell
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return photoStream.photos.count
    }
}



extension PhotoStreamViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let dummyImage = UIImage(named:"gt40_rhinluch.jpg")!

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let lineSpacing = flowLayout.minimumLineSpacing

        let width = collectionView.bounds.width - 2 * lineSpacing
        let height = dummyImage.size.height * (width / dummyImage.size.width)
        return CGSize(width: width, height: height)
    }
}