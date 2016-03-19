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

// MARK: TransferableStructConvertible
extension PokedexEntry {
    // MARK: Types
    typealias StructType = PokedexEntryStruct
    
    // MARK: Properties
    var structValue: StructType {
        return PokedexEntryStruct(identifier: self.identifier,
            nationalDexNumber: self.nationalDexNumber,
            localDexNumber: self.localDexNumber,
            iconURL: self.iconURL,
            name: self.name,
            type1: self.type1!.structValue,
            type2: self.type2?.structValue)
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
            
        case 387...494:
            return "Sinnoh"
            
        case 495...649:
            return "Unova"
            
        case 650...721:
            return "Kalos"
            
        default:
            return "???"
        }
    }
    
    var regionArea: CGRect {
        var rect: CGRect
        
        switch self.regionName {
        case "Kanto":
            rect = CGRect(x: 475, y: 212, width: 323, height: 194)
            
        case "Johto":
            rect = CGRect(x: 202, y: 217, width: 275, height: 194)
            
        case "Hoenn":
            rect = CGRect(x: 12, y: 355, width: 323, height: 211)
            
        case "Sinnoh":
            rect = CGRect(x: 786, y: 0, width: 357, height: 262)
            
        case "Unova":
            rect = CGRect(x: 0, y: 738, width: 323, height: 262)
            
        case "Kalos":
            rect = CGRect(x: 829, y: 789, width: 299, height: 211)
            
        default:
            rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        
        rect = CGRectInset(rect, rect.width * -0.25, rect.height * -0.25)
        return rect
    }
}