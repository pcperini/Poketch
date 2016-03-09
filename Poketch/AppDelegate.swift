//
//  AppDelegate.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/3/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Properties
    var window: UIWindow?
    
    static var sharedAppDelegate: AppDelegate!
    var rootViewController: ViewController? {
        return self.window?.rootViewController as? ViewController
    }
    
    // MARK: Lifecycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        AppearanceSwizzling.setupAppearances()
        AppDelegate.sharedAppDelegate = self
        
        return true
    }
}

