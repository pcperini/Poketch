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
import WatchConnectivity


class EntriesListInterfaceController: WKInterfaceController {
    // MARK: Properties
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var endOfPageLabelContainer: WKInterfaceGroup!
    
    @IBOutlet var previousSectionButton: WKInterfaceButton!
    @IBOutlet var previousPageButton: WKInterfaceButton!
    @IBOutlet var nextPageButton: WKInterfaceButton!
    @IBOutlet var nextSectionButton: WKInterfaceButton!
    
    var session: WCSession!
    
    var entriesOnPage: [PokedexEntryStruct] = []
    var totalEntries = 0
    
    var sortState: SortState = .Region {
        didSet {
            self.page = 0
        }
    }
    
    let sectionSize: Int = 90
    let pageSize: Int = 9
    var page: Int = 0 {
        willSet {
            [
                self.previousSectionButton,
                self.previousPageButton,
                self.nextPageButton,
                self.nextSectionButton
            ].forEach { $0.setEnabled(false) }
        }
        
        didSet { self.reloadData() }
    }
    
    var lastPage: Int {
        return self.totalEntries / self.pageSize
    }
    
    // MARK: Lifecycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.session = WCSession.defaultSession()
        self.session.delegate = self
        self.session.activateSession()
        
        self.table.ig_dataSource = self
        self.reloadData()
    }

    // MARK: Responders
    @IBAction func previousPageButtonWasPressed(sender: WKInterfaceButton?) {
        self.page -= 1
    }
    
    @IBAction func previousSectionButtonWasPressed(sender: WKInterfaceButton?) {
        self.page = max(self.page - (self.sectionSize / self.pageSize), 0)
    }
    
    @IBAction func nextPageButtonWasPressed(sender: WKInterfaceButton?) {
        self.page += 1
    }
    
    @IBAction func nextSectionButtonWasPressed(sender: WKInterfaceButton?) {
        self.page = min(self.page + (self.sectionSize / self.pageSize), self.lastPage)
    }
    
    @IBAction func alphabeticalSortButtonWasPressed() {
        self.sortState = .Alphabetical
    }
    
    @IBAction func regionSortButtonWasPressed() {
        self.sortState = .Region
    }
    
    @IBAction func typeSortButtonWasPressed() {
        self.sortState = .Type
    }
    
    // MARK: Data Handlers
    func reloadData() {
        let request = ["fetch": [
            "class": "PokedexEntry",
            "limit": self.pageSize,
            "offset": self.page * self.pageSize,
            "sort": self.sortState.rawValue
        ]]
        
        self.session.activateSession()
        self.session.sendMessage(request, replyHandler: { (resp: [String : AnyObject]) in
            self.entriesOnPage = (resp["results"] as! [NSDictionary]).map { PokedexEntryStruct(transferableObject: $0)! }
            self.totalEntries = (resp["total"] as! NSNumber).integerValue
            
            self.nextPageButton.setEnabled(self.page != self.lastPage)
            self.nextSectionButton.setEnabled(self.page != self.lastPage)
            
            self.previousPageButton.setEnabled(self.page != 0)
            self.previousSectionButton.setEnabled(self.page != 0)
            
            self.table.reloadData()
            self.endOfPageLabelContainer.setHidden(false)
        }, errorHandler: nil)
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
        let entry = self.entriesOnPage[indexPath.row]
                
        row.iconImage.setImageWithURL(entry.iconURL, placeholderImage: nil)
        
        row.nationalDexNumberLabel.setText(entry.nationalDexNumber)
        row.titleLabel.setText(entry.name)
        
        row.type1Indicator.setBackgroundColor(entry.type1.color)
        if let type2 = entry.type2 {
            row.type2Indicator.setHidden(false)
            row.type2Indicator.setBackgroundColor(type2.color)
        } else {
            row.type2Indicator.setHidden(true)
        }
    }
}

extension EntriesListInterfaceController: WCSessionDelegate {}