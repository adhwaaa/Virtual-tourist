//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Komil Bagshi on 05/01/2019.
//  Copyright © 2019 KamelBaqshi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "MyVirtualTourist")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.        
        //DataController Injection
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let mapVC = navigationController.topViewController as! TravelLocationMapViewController
        mapVC.dataController = dataController
        
        return true
    }
}
