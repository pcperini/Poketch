//
//  EntryDetailsInterfaceController.swift
//  Poketch
//
//  Created by PATRICK PERINI on 4/10/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import WatchKit
import IGInterfaceDataTable
import WatchConnectivity


class EntryDetailsInterfaceController: WKInterfaceController {
    // MARK: Properties
    @IBOutlet var loadLabel: WKInterfaceLabel!
    @IBOutlet var typeEffectivenessesTable: WKInterfaceTable!
    @IBOutlet var image: WKInterfaceImage!

    var session: WCSession!
    
    var entry: PokedexEntryStruct!
    var entryDetails: PokedexEntryDetailsStruct?
    var sortedTypeEffectivenesses: [(PokedexTypeStruct, Float)] {
        guard let effectivnesses = self.entryDetails?.typeEffectivenesses else {
            return []
        }
        
        return effectivnesses.sort {
            $0.1 > $1.1
        }
    }
    
    // MARK: Lifecycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let entryObject = context as! NSDictionary
        self.entry = PokedexEntryStruct(transferableObject: entryObject)
        
        self.session = WCSession.defaultSession()
        self.session.delegate = self
        self.session.activateSession()
        
        self.typeEffectivenessesTable.ig_dataSource = self
        self.reloadData()
    }
    
    // MARK: Data Handlers
    func reloadData() {
        let request = ["fetch": [
            "class": "PokedexEntryDetails",
            "identifier": self.entry.identifier
        ]]
        
        self.session.activateSession()
        self.session.sendMessage(request, replyHandler: { (resp: [String : AnyObject]) in
            guard let entryDetailsObject = (resp["results"] as! [NSDictionary]).first else {
                self.loadLabel.setText("\nload on phone")
                dispatch_after(5.0) {
                    self.popController()
                }
                
                return
            }
            
            self.loadLabel.setHidden(true)
            self.entryDetails = PokedexEntryDetailsStruct(transferableObject: entryDetailsObject)
            
            if let entryDetails = self.entryDetails {
                self.typeEffectivenessesTable.reloadData()
                self.image.setImageWithURL(entryDetails.detailImageURL, placeholderImage: nil)
            }
        }, errorHandler: nil)
    }
}

extension EntryDetailsInterfaceController: IGInterfaceTableDataSource {
    func numberOfRowsInTable(table: WKInterfaceTable!, section: Int) -> Int {
        return self.entryDetails?.typeEffectivenesses.count ?? 0
    }
    
    func table(table: WKInterfaceTable!, rowIdentifierAtIndexPath indexPath: NSIndexPath!) -> String! {
        return TypeEffectivenessRow.rowType
    }
    
    func table(table: WKInterfaceTable!, configureRowController rowController: NSObject!, forIndexPath indexPath: NSIndexPath!) {
        guard let row = rowController as? TypeEffectivenessRow else { return }
        let typeEffectiveness = self.sortedTypeEffectivenesses[indexPath.row]
        
        row.background.setBackgroundColor(typeEffectiveness.0.color)
        
        row.nameLabel.setText(typeEffectiveness.0.abbreviatedName)
        row.nameLabel.setHorizontalAlignment(.Left)
        
        row.effectivenessLabel.setText("\(typeEffectiveness.1.fraction)x")
        row.effectivenessLabelBackground.setHorizontalAlignment(.Right)
        
        if typeEffectiveness.1 < 1 {
            row.nameLabel.setHorizontalAlignment(.Right)
            row.effectivenessLabelBackground.setHorizontalAlignment(.Left)
        }
    }
}

extension EntryDetailsInterfaceController: WCSessionDelegate {}
