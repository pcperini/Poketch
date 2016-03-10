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
        
        let rootVC = AppDelegate.sharedAppDelegate.rootViewController
        
        rootVC?.titleLabel.text = self.entry.name
        rootVC?.indicatorImageView.backgroundColor = UIColor.blackColor()
        rootVC?.indicatorImageView.setImageWithURL(self.entry.iconURL,
            placeholderImage: nil)
        
        rootVC?.sortFilterButtonHidden = true
    }
}
