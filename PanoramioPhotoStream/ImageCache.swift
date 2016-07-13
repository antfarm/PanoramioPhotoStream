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

        cache.delegate = self
    }


    func setImage(image: UIImage, forKey key: String) {

        self.cache.setObject(image, forKey: key)
    }

    
    func imageForKey(key: String) -> UIImage? {

        if let cachedImage = cache.objectForKey(key) as! UIImage? {
            return cachedImage
        }

        return nil
    }
}



extension ImageCache: NSCacheDelegate {

    func cache(cache: NSCache, willEvictObject obj: AnyObject) {

        let image = obj as! UIImage

        print("Evicting image from cache: \(image)")
    }
}