//
//  BCPokedexEntryDetails.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/21/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import RealmSwift
import AFNetworking
import Ono

// MARK: Entries
extension BulbapediaClient {
    // MARK: Accessors
    func fetchDetailsForEntry(entry: PokedexEntry, priority: Bool = true, callback: (PokedexEntryDetails, NSError?) -> Void) {
        guard entry.details == nil else {
            callback(entry.details!, nil)
            return
        }
        
        let realm = try! Realm()
        var entryDetails: PokedexEntryDetails = PokedexEntryDetails()
        var error: NSError?
        
        self.GET(entry.sourceURL.absoluteString, priority: priority, success: { (_, resp: AnyObject) in
            realm.beginWrite()
            defer {
                entry.details = entryDetails
                try! realm.commitWrite()
                
                callback(entryDetails, error)
            }
            
            guard let doc = resp as? ONOXMLDocument else { return }
            
            // Base Stats:
            let stats = doc.children("a").filter { $0.attributes["title"] as? String == "Statistic" }
                .map { ($0.children("span").first?.stringValue(), $0.parent.parent.children("th").last?.stringValue()) }
            
            for stat in stats {
                guard let statName = stat.0, let statVal = (stat.1 as NSString?)?.integerValue else {
                    continue
                }
                
                switch statName {
                case "HP":
                    entryDetails.baseHP = statVal
                case "Attack":
                    entryDetails.baseAttack = statVal
                case "Defense":
                    entryDetails.baseDefense = statVal
                case "Sp.Atk":
                    entryDetails.baseSpAttack = statVal
                case "Sp.Def":
                    entryDetails.baseSpDefense = statVal
                case "Speed":
                    entryDetails.baseSpeed = statVal
                default:
                    continue
                }
            }
            
            // Type Effectivenesses:
            let typeSets = doc.children("a").filter { ($0.attributes["title"] as? String)?.hasSuffix("(type)") ?? false }
                .map { $0.parent.parent.parent.children("td") }
                .filter { $0.count == 2 }
                .filter { $0.last?.stringValue().rangeOfString("×") != nil }
            let types = typeSets.map { ($0.first?.children("b").first?.stringValue(), $0.last?.stringValue()) }
            
            var seenTypeNames: Set<String> = []
            for type in types {
                guard let typeName = type.0, typeValString = type.1 else { continue }
                
                let typeMult: Float
                let typeVal = typeValString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                switch typeVal {
                case "0×":
                    typeMult = 0.00
                    
                case "¼×":
                    typeMult = 0.25
                case "½×":
                    typeMult = 0.50
                    
                case "2×":
                    typeMult = 2.00
                case "4×":
                    typeMult = 4.00
                    
                default:
                    continue
                }
                
                guard let type = realm.objects(PokedexType).filter("name=='\(typeName)'").first else { continue }
                guard !seenTypeNames.contains(type.name) else { continue }
                
                seenTypeNames.insert(type.name)
                
                let typeEffectiveness = PokedexTypeEffectiveness()
                typeEffectiveness.type = type
                typeEffectiveness.effectiveness = typeMult
                
                entryDetails.typeEffectivenesses.append(typeEffectiveness)
            }
            
            // Sprites
            let sprite = doc.children("small").filter { $0.stringValue().hasPrefix("Generation V") }
                .map { $0.parent.parent.parent }
                .filter { !$0.children("img").isEmpty }
                .flatMap { $0.children("img").first }
                .flatMap { $0.attributes["src"] as? String }
                .first

            entryDetails.detailImageURLString = sprite ?? ""
        }, failure: { (_, error: NSError) in
            callback(entryDetails, error)
        })
    }
}
