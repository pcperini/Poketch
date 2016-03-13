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
    
    // MARK: Lifecycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        AppearanceSwizzling.setupAppearances()        
        return true
    }
}

