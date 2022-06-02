//
//  AppDelegate.swift
//  PhotoApp
//
//  Created by Vignesh Radhakrishnan on 02/06/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        let listViewController = PhotoListViewController()
//        let navigationController = UINavigationController(rootViewController: listViewController)
//        
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

