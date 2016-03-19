//
//  PokedexType.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/3/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import RealmSwift

class PokedexType: Object {
    // MARK: Properties
    dynamic var name: String = ""
    var abbreviatedName: String {
        var name = self.name
        switch name {
        case "Fighting":
            name = "Fight"
        case "Electric":
            name = "Electr"
        case "Psychic":
            name = "Psychc"
        case "Unknown":
            name = "???"
        default:
            break
        }
        
        return name.uppercaseString
    }
    
    dynamic var colorString: String = ""
    var color: UIColor {
        return UIColor(hexString: self.colorString)
    }
    
    // MARK: Class Properties
    override static func primaryKey() -> String? {
        return "name"
    }
}

// MARK: TransferableStructConvertible
extension PokedexType {
    // MARK: Types
    typealias StructType = PokedexTypeStruct
    
    // MARK: Properties
    var structValue: PokedexTypeStruct {
        return PokedexTypeStruct(name: self.name,
            color: self.color)
    }
}