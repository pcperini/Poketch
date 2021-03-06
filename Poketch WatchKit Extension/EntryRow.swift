//
//  EntryRow.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/13/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import WatchKit

class EntryRow: Row {
    // MARK: Properties
    @IBOutlet var iconImage: WKInterfaceImage!
    
    @IBOutlet var nationalDexNumberLabel: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    @IBOutlet var type1Indicator: WKInterfaceGroup!
    @IBOutlet var type2Indicator: WKInterfaceGroup!
}
