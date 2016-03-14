//
//  InterfaceController.swift
//  Poketch WatchKit Extension
//
//  Created by PATRICK PERINI on 3/3/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import WatchKit
import Foundation
import IGInterfaceDataTable


class EntriesListInterfaceController: WKInterfaceController {
    // MARK: Properties
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var previousPageButton: WKInterfaceButton!
    @IBOutlet var nextPageButton: WKInterfaceButton!
    
    var entries: [String] = ["Hello", "World", "Foo", "Bar"]
    var entriesOnPage: [String] {
        let startIndex = self.page * self.pageSize
        let endIndex: Int
        
        if self.onLastPage {
            endIndex = self.entries.count
        } else {
            endIndex = startIndex + self.pageSize
        }
        
        return Array(self.entries[startIndex ..< endIndex])
    }
    
    var pageSize: Int = 1
    var page: Int = 0 {
        didSet {
            self.reloadData()
        }
    }
    
    var onLastPage: Bool {
        return (self.page * self.pageSize) + self.pageSize
            >= self.entries.count
    }
    
    // MARK: Lifecycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.table.ig_dataSource = self
        self.reloadData()
    }

    // MARK: Responders
    @IBAction func previousPageButtonWasPressed(sender: WKInterfaceButton?) {
        self.page -= 1
    }
    
    @IBAction func nextPageButtonWasPressed(sender: WKInterfaceButton?) {
        self.page += 1
    }
    
    // MARK: Data Handlers
    func reloadData() {
        self.nextPageButton.setEnabled(!self.onLastPage)
        self.previousPageButton.setEnabled(self.page != 0)
        self.table.reloadData()
    }
}

extension EntriesListInterfaceController: IGInterfaceTableDataSource {
    func numberOfRowsInTable(table: WKInterfaceTable!, section: Int) -> Int {
        return self.entriesOnPage.count
    }
    
    func table(table: WKInterfaceTable!, rowIdentifierAtIndexPath indexPath: NSIndexPath!) -> String! {
        return EntryRow.rowType
    }
    
    func table(table: WKInterfaceTable!, configureRowController rowController: NSObject!, forIndexPath indexPath: NSIndexPath!) {
        guard let row = rowController as? EntryRow else { return }
        row.titleLabel.setText(self.entriesOnPage[indexPath.row])
    }
}