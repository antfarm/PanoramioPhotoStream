//
//  AppDelegate.swift
//  PanoramioPhotoStream
//

import UIKit
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let photoStreamViewController = window?.rootViewController as! PhotoStreamViewController

        photoStreamViewController.locationManager = CLLocationManager()
        photoStreamViewController.panoramioClient = PanoramioClient()
        photoStreamViewController.photoStream = PhotoStream()
        photoStreamViewController.imageStore = ImageStore()

        return true
    }


    func applicationWillTerminate(application: UIApplication) {

        ImageStore.deleteImageDirectory()
    }
}

