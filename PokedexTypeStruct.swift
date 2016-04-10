//
//  PokedexTypeStruct.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/16/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import Foundation
import UIKit

struct PokedexTypeStruct {
    // MARK: Properties
    let name: String
    let color: UIColor
    
    var abbreviatedName: String {
        return self.name.dexAbbreviation
    }
}

extension PokedexTypeStruct: Transferable {
    // MARK: Initializers
    init?(transferableObject: NSDictionary) {
        guard let name = transferableObject["name"] as? String,
            let colorString = transferableObject["color"] as? String else {
                return nil
        }
        
        self.name = name
        self.color = UIColor(hexString: colorString)
    }
    
    // MARK: Properties
    var transferableObject: NSDictionary {
        return [
            "name": self.name as NSString,
            "color": self.color.hexString as NSString
        ]
    }
}

func ==(lhs: PokedexTypeStruct, rhs: PokedexTypeStruct) -> Bool {
    return lhs.name == rhs.name
}

extension PokedexTypeStruct: Hashable {
    // MARK: Properties
    var hashValue: Int {
        return self.name.hashValue
    }
}

extension String {
    var dexAbbreviation: String {
        var name = self
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
}