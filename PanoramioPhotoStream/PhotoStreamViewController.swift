//
//  PhotoStreamViewController.swift
//  PanoramioPhotoStream
//
//  Created by sean on 09/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import UIKit


class PhotoStreamViewController: UIViewController {

    @IBOutlet var startButtonItem: UIBarButtonItem!
    @IBOutlet var stopButtonItem: UIBarButtonItem!

    @IBOutlet var photoCollectionView: UICollectionView!


    let dummyImage = UIImage(named:"gt40_rhinluch.jpg")!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
    }


    @IBAction func startStreaming(sender: UIBarButtonItem) {

        startButtonItem.enabled = false
        stopButtonItem.enabled = true

        print("Starting ...")
    }


    @IBAction func stopStreaming(sender: UIBarButtonItem) {

        stopButtonItem.enabled = false
        startButtonItem.enabled = true

        print("Stopping ...")
    }
}


extension PhotoStreamViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCollectionViewCell.reuseId, forIndexPath: indexPath) as! PhotoCollectionViewCell

        cell.photoImageView.image = dummyImage

        return cell
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 10
    }
}


extension PhotoStreamViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let lineSpacing = flowLayout.minimumLineSpacing // set in Interface BUilder

        let width = collectionView.bounds.width - 2 * lineSpacing
        let height = dummyImage.size.height * (width / dummyImage.size.width)

        return CGSize(width: width, height: height)
    }
}


