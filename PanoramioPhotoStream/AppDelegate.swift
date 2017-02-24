//
//  AppDelegate.swift
//  PanoramioPhotoStream
//

import UIKit
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let photoStreamViewController = window?.rootViewController as! PhotoStreamViewController

        photoStreamViewController.locationManager = CLLocationManager()
        photoStreamViewController.panoramioClient = PanoramioClient()
        photoStreamViewController.photoStream = PhotoStream()
        photoStreamViewController.imageStore = ImageStore()

        return true
    }


    func applicationWillTerminate(_ application: UIApplication) {

        ImageStore.deleteImageDirectory()
    }
}

