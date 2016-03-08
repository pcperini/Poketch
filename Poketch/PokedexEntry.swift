//
//  PokedexEntry.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/3/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import Foundation
import RealmSwift

class PokedexEntry: Object {
    // MARK: Properties
    dynamic var identifier: Int = 0
    
    dynamic var nationalDexNumber: String = ""
    dynamic var localDexNumber: String = ""
    
    dynamic var iconURLString: String = ""
    var iconURL: NSURL {
        return NSURL(string: self.iconURLString)!
    }
    
    dynamic var name: String = ""
    
    dynamic var type1: PokedexType? = nil
    dynamic var type2: PokedexType? = nil
    
    // MARK: Class Properties
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

// MARK: Hashable
func ==(lhs: PokedexEntry, rhs: PokedexEntry) -> Bool {
    return lhs.identifier == rhs.identifier
}

extension PokedexEntry: Hashable {
    override var hashValue: Int {
        return self.identifier
    }
}

// MARK: Regions
extension PokedexEntry {
    // MARK: Properties
    var regionName: String {
        switch self.identifier {
        case 1...151:
            return "Kanto"
            
        case 152...251:
            return "Johto"
            
        case 252...386:
            return "Hoenn"
            
        case 387...493:
            return "Sinnoh"
            
        case 494...649:
            return "Unova"
            
        case 650...721:
            return "Kalos"
            
        default:
            return "???"
        }
    }
}