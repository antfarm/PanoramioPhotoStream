//
//  ImageCache.swift
//  PanoramioPhotoStream
//
//  Created by sean on 12/07/16.
//  Copyright © 2016 antfarm. All rights reserved.
//

import UIKit


class ImageCache: NSObject {

    private let cache = NSCache()


    override init() {
        super.init()

        ImageCache.deleteImageDirectory()
        ImageCache.createImageDirectory()

        cache.delegate = self
    }

    
    func setImage(image: UIImage, forKey key: String) {

        self.cache.setObject(image, forKey: key)

        if let rawData = UIImageJPEGRepresentation(image, Config.ImageStore.jpegCompressionQuality) {

            rawData.writeToURL(imageUrlForKey(key), atomically: true)
        }
    }

    
    func imageForKey(key: String) -> UIImage? {

        if let cachedImage = cache.objectForKey(key) as! UIImage? {

            return cachedImage
        }

        if let savedImage = UIImage(contentsOfFile: imageUrlForKey(key).path!) {

            cache.setObject(savedImage, forKey: key)
            return savedImage
        }

        return nil
    }


    private static var fileManager: NSFileManager {
        get {
            return NSFileManager.defaultManager()
        }
    }


    private static let imageDirectoryURL = fileManager
        .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        .URLByAppendingPathComponent(Config.ImageStore.imagesDirName)


    private static var imageDirectoryExists: Bool {
        get {
            return fileManager.fileExistsAtPath(ImageCache.imageDirectoryURL.path!)
        }
    }


    static func createImageDirectory() {

        guard !imageDirectoryExists else {
            return
        }

        print("Creating image directory.")

        do {
            try fileManager.createDirectoryAtURL(ImageCache.imageDirectoryURL, withIntermediateDirectories: false, attributes: nil)
        }
        catch {
            print("Error creating image directory: \(error)")
        }
    }


    static func deleteImageDirectory() {

        guard imageDirectoryExists else {
            return
        }

        print("Deleting image directory.")

        do {
            try fileManager.removeItemAtURL(ImageCache.imageDirectoryURL)
        }
        catch {
            print("Error deleting image directory: \(error)")
        }
    }


    private func imageUrlForKey(key: String) -> NSURL {

        return ImageCache.imageDirectoryURL.URLByAppendingPathComponent(key)
    }
}



extension ImageCache: NSCacheDelegate {

    func cache(cache: NSCache, willEvictObject obj: AnyObject) {

        let image = obj as! UIImage
        print("Evicting image from cache: \(image)")
    }
}