//
//  ImageStore.swift
//  PanoramioPhotoStream
//

import UIKit


class ImageStore: NSObject {

    private let cache = NSCache<NSString, UIImage>()


    override init() {
        super.init()

        ImageStore.deleteImageDirectory()
        ImageStore.createImageDirectory()

        cache.delegate = self
    }

    
    func setImage(image: UIImage, forKey key: String) {

        cache.setObject(image, forKey: key as NSString)

        if let rawData = UIImageJPEGRepresentation(image, Config.ImageStore.jpegCompressionQuality) {
            try! rawData.write(to: imageUrlForKey(key: key), options: [.atomicWrite])
        }
    }

    
    func imageForKey(key: String) -> UIImage? {

        if let cachedImage = cache.object(forKey: key as NSString) {
            return cachedImage
        }

        if let savedImage = UIImage(contentsOfFile: imageUrlForKey(key: key).path) {
            cache.setObject(savedImage, forKey: key as NSString)
            return savedImage
        }

        return nil
    }


    private static var fileManager: FileManager {
        get {
            return FileManager.default
        }
    }


    private static let imageDirectoryURL = fileManager
        .urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent(Config.ImageStore.imagesDirName)


    private static var imageDirectoryExists: Bool {
        get {
            return fileManager.fileExists(atPath: ImageStore.imageDirectoryURL.path)
        }
    }


    static func createImageDirectory() {

        guard !imageDirectoryExists else {
            return
        }

        print("Creating image directory.")

        do {
            try fileManager.createDirectory(at: ImageStore.imageDirectoryURL, withIntermediateDirectories: false, attributes: nil)
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
            try fileManager.removeItem(at: ImageStore.imageDirectoryURL)
        }
        catch {
            print("Error deleting image directory: \(error)")
        }
    }


    private func imageUrlForKey(key: String) -> URL {

        return ImageStore.imageDirectoryURL.appendingPathComponent(key)
    }
}



extension ImageStore: NSCacheDelegate {

    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {

        let image = obj as! UIImage
        print("Evicting image from cache: \(image)")
    }
}
