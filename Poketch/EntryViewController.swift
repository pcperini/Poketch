//
//  EntryViewController.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/8/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {
    // MARK: Properties
    var entry: PokedexEntry!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().postNotificationName(FrameViewController.FrameNeedsUpdated,
            object: nil,
            userInfo: [FrameViewController.UpdateAnimatedUserInfoKey: true])
    }
}

extension EntryViewController: FrameViewControllerDataType {
    // MARK: Properties
    override var title: String? {
        get { return self.entry.name }
        set {}
    }
    
    var indicatorImageURL: NSURL? {
        return self.entry.iconURL
    }
    
    var indiactorImageBackgroundColor: UIColor? {
        return UIColor.blackColor()
    }
    
    var filterButtonHidden: Bool {
        return true
    }
}