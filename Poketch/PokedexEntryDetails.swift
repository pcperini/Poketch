//
//  PokedexEntryDetails.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/21/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import RealmSwift

class PokedexEntryDetails: Object {
    // MARK: Properties
    dynamic var detailImageURLString: String = ""
    var detailImageURL: NSURL {
        return NSURL(string: self.detailImageURLString)!
    }
    
    dynamic var baseHP: Int = 0
    dynamic var baseAttack: Int = 0
    dynamic var baseDefense: Int = 0
    dynamic var baseSpAttack: Int = 0
    dynamic var baseSpDefense: Int = 0
    dynamic var baseSpeed: Int = 0
    
    let typeEffectivenesses = List<PokedexTypeEffectiveness>()
}

// MARK: TransferableStructConvertible
extension PokedexEntryDetails {
    // MARK: Types
    typealias StructType = PokedexEntryDetailsStruct
    
    // MARK: Properties
    var structValue: StructType {
        var typeEffectivenesses: [PokedexTypeStruct: Float] = [:]
        self.typeEffectivenesses.forEach {
            typeEffectivenesses[$0.type.structValue] = $0.effectiveness
        }
        
        return PokedexEntryDetailsStruct(detailImageURL: self.detailImageURL,
            typeEffectivenesses: typeEffectivenesses)
    }
}