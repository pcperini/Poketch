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
        AppDelegate.sharedAppDelegate.rootViewController?.titleLabel.text = self.entry.name
    }
}
