//
//  BCPokedexEntries.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/21/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import RealmSwift
import Ono

// MARK: Entries
extension BulbapediaClient {
    // MARK: Static Properties
    private static let entriesPath = "wiki/List_of_Pokemon_by_National_Pokedex_number"
    
    // MARK: Accessors
    func fetchEntries(callback: ([PokedexEntry], NSError?) -> Void) {
        self.requestManager.GET(BulbapediaClient.entriesPath, parameters: nil, success: { (_, resp: AnyObject) in
            let realm = try! Realm()
            
            var entries: [PokedexEntry] = []
            defer { callback(entries, nil) }
            
            guard let doc = resp as? ONOXMLDocument else { return }
            let possibleRows: [[ONOXMLElement]] = doc.children("table tr")
                .filter { !$0.children("td a img").isEmpty }
                .map { $0.children("td") }
            let type1BackgroundColors: [UIColor] = possibleRows.map { $0[4].hexColorWithCSSTag("background")! }
            let type2BackgroundColors: [UIColor?] = possibleRows.map {
                guard $0.count > 5 else { return nil }
                return $0[5].hexColorWithCSSTag("background")!
            }
            
            entries = possibleRows.enumerate().map {
                realm.beginWrite()
                defer { try! realm.commitWrite() }
                
                let entry = PokedexEntry()
                
                entry.nationalDexNumber = $0.element[1].stringValue()
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                entry.localDexNumber = $0.element[0].stringValue()
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                let identifierString: NSString = entry.nationalDexNumber.stringByReplacingOccurrencesOfString("#", withString: "")
                entry.identifier = identifierString.integerValue
                
                if let existingEntry = realm.objects(PokedexEntry).filter("identifier==\(entry.identifier)").first {
                    return existingEntry
                }
                
                let iconURLString = (($0.element[2].children[0] as! ONOXMLElement)
                    .children[0] as! ONOXMLElement)
                    .attributes["src"] as! String
                entry.iconURLString = iconURLString
                
                entry.name = $0.element[3].stringValue()
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                let type1Name = $0.element[4].stringValue()
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                if let type1 = realm.objects(PokedexType).filter("name=='\(type1Name)'").first {
                    entry.type1 = type1
                } else {
                    entry.type1 = PokedexType()
                    entry.type1?.name = type1Name
                    entry.type1?.colorString = type1BackgroundColors[$0.index].hexString
                }
                
                if let type2Color = type2BackgroundColors[$0.index] {
                    let type2Name = $0.element[5].stringValue()
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    if let type2 = realm.objects(PokedexType).filter("name=='\(type2Name)'").first {
                        entry.type2 = type2
                    } else {
                        entry.type2 = PokedexType()
                        entry.type2?.name = type2Name
                        entry.type2?.colorString = type2Color.hexString
                    }
                }
                
                realm.add(entry)
                return entry
            }
        }, failure: { (_, error: NSError) in
            callback([], error)
        })
    }
}

extension PokedexEntry {
    // MARK: Properties
    var sourceURL: NSURL {
        let name = self.name.stringByReplacingOccurrencesOfString("♂", withString: "M")
            .stringByReplacingOccurrencesOfString("♀", withString: "F")
            .stringByReplacingOccurrencesOfString("é", withString: "e")
        
        return NSURL(string: "http://bulbapedia.bulbagarden.net/wiki/\(name)_(Pokemon)")!
    }
}
