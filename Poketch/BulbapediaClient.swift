//
//  BulbapediaClient.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/3/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import Foundation
import AFNetworking
import Ono
import AFOnoResponseSerializer
import PromiseKit
import RealmSwift

struct BulbapediaClient {
    // MARK: Static Properties
    private static let baseURLString = "http://bulbapedia.bulbagarden.net"
    
    // MARK: Properties
    let requestManager: AFHTTPRequestOperationManager = {
        let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: baseURLString)!)
        manager.responseSerializer = AFOnoResponseSerializer.HTMLResponseSerializer()
        return manager
    }()
}

// MARK: Entries
extension BulbapediaClient {
    // MARK: Static Properties
    private static let entriesPath = "wiki/List_of_Pokemon_by_National_Pokedex_number"
    
    // MARK: Accessors
    func fetchEntries() -> Promise<[PokedexEntry]> {
        return Promise(resolver: { (resolver: ([PokedexEntry], NSError?) -> Void) in
            self.requestManager.GET(BulbapediaClient.entriesPath, parameters: nil, success: { (_, resp: AnyObject) in
                let realm = try! Realm()

                var entries: [PokedexEntry] = []
                defer { resolver(entries, nil) }
                
                guard let doc = resp as? ONOXMLDocument else { return }
                let possibleRows: [[ONOXMLElement]] = ((doc.CSS("table tr") as! NSEnumerator).allObjects as! [ONOXMLElement])
                    .filter { !(($0.CSS("td a img") as? NSEnumerator)?.allObjects.isEmpty ?? true) }
                    .map { ($0.CSS("td") as! NSEnumerator).allObjects as! [ONOXMLElement] }
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
                resolver([], error)
            })
        })
    }
}

extension PokedexEntry {
    // MARK: Properties
    var sourceURL: NSURL {
        return NSURL(string: "http://bulbapedia.bulbagarden.net/wiki/\(self.name)_(Pokemon)")!
    }
}

// MARK: Extractors
extension ONOXMLElement {
    func hexColorWithCSSTag(cssTag: String) -> UIColor? {
        let attrs = self.attributes
        guard let style = attrs["style"] as? String else { return nil }
        
        let scanner = NSScanner(string: style)
        scanner.scanUpToString("\(cssTag):#", intoString: nil)
        guard scanner.scanString("\(cssTag):#", intoString: nil) else { return nil }
        
        var hexVal: UInt32 = 0
        scanner.scanHexInt(&hexVal)

        return UIColor(hexVal: hexVal)
    }
}
