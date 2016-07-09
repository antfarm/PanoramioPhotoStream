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

    @IBOutlet var photoCollectionView: UICollectionView!

    var locationManager: CLLocationManager!


    private var photos: [UIImage?] = []
    private var photoLocations: [CLLocation] = []

    private let dummyImage = UIImage(named:"gt40_rhinluch.jpg")!


    override func viewDidLoad() {
        super.viewDidLoad()

        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
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


    func addLocation(location: CLLocation) {

        photoLocations.insert(location, atIndex: 0)

        print("Adding Location #\(photoLocations.count)")

        photos.insert(dummyImage, atIndex: 0)

        // TODO: prevent scrolling 
        photoCollectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
        //photoCollectionView.reloadData()
    }
}


extension PhotoStreamViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        for location in locations {

            guard photoLocations.count > 0 else {
                addLocation(location)
                continue
            }

            let distanceToLastPhotoLocation = photoLocations.first!.distanceFromLocation(location)

            print("Distance: \(distanceToLastPhotoLocation)")

            if distanceToLastPhotoLocation >= Config.distanceBetweenPhotoLocations {
                addLocation(location)
                continue
            }
        }
    }
}


extension PhotoStreamViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCollectionViewCell.reuseId, forIndexPath: indexPath) as! PhotoCollectionViewCell

        if let photo = photos[indexPath.row] {
            cell.photoImageView.image = photo
        }

        return cell
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return photoLocations.count
    }
}


extension PhotoStreamViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let lineSpacing = flowLayout.minimumLineSpacing

        let width = collectionView.bounds.width - 2 * lineSpacing
        let height = dummyImage.size.height * (width / dummyImage.size.width)
        return CGSize(width: width, height: height)
    }
}