//
//  PokedexEntryDetailsStruct.swift
//  Poketch
//
//  Created by PATRICK PERINI on 4/10/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

struct PokedexEntryDetailsStruct {
    // MARK: Properties
    let detailImageURL: NSURL
    let typeEffectivenesses: [PokedexTypeStruct: Float]
}

extension PokedexEntryDetailsStruct: Transferable {
    // MARK: Initializers
    init?(transferableObject: NSDictionary) {
        guard let detailImageURLString = transferableObject["detailImageURL"] as? String,
            let detailImageURL = NSURL(string: detailImageURLString),
            let typeEffectivenessDicts = transferableObject["typeEffectivenesses"] as? [NSDictionary: NSNumber] else {
                return nil
        }
        
        self.detailImageURL = detailImageURL
        
        var typeEffectivenesses: [PokedexTypeStruct: Float] = [:]
        for (key, value) in typeEffectivenessDicts {
            guard let type = PokedexTypeStruct(transferableObject: key) else {
                return nil
            }
            
            typeEffectivenesses[type] = value.floatValue
        }
        
        self.typeEffectivenesses = typeEffectivenesses
    }
    
    // MARK: Properties
    var transferableObject: NSDictionary {
        var typeEffectivenesses: [NSDictionary: NSNumber] = [:]
        for (type, multiplier) in self.typeEffectivenesses {
            typeEffectivenesses[type.transferableObject] = NSNumber(float: multiplier)
        }
        
        return [
            "detailImageURL": self.detailImageURL.absoluteString as NSString,
            "typeEffectivenesses": typeEffectivenesses as NSDictionary
        ]
    }
}