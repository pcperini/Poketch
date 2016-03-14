//
//  Row.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/13/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import WatchKit

class Row: NSObject {
    // MARK: Properties
    class var rowType: String {
        return NSStringFromClass(self)
    }
    
    // MARK: Configuration
    func configure() {
    }
}

extension WKInterfaceTable {
    func rowAtIndex<RowType: Row>(index: Int, ofType type: RowType.Type) -> RowType? {
        let row = self.rowControllerAtIndex(index) as? RowType
        row?.configure()
        return row
    }
}