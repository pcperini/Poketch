//
//  InterfaceController.swift
//  Poketch WatchKit Extension
//
//  Created by PATRICK PERINI on 3/3/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import WatchKit
import Foundation
//import IGInterfaceDataTable


class EntriesListInterfaceController: WKInterfaceController {
    // MARK: Properties
    @IBOutlet var table: WKInterfaceTable!
    
    // MARK: Lifecycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
//        self.table.ig_
    }

    // MARK: Responders
    @IBAction func filterButtonWasPressed(sender: WKInterfaceButton?) {
    
    }
}
