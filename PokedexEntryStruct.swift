//
//  PokedexEntryStruct.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/16/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import Foundation

struct PokedexEntryStruct {
    // MARK: Properties
    let identifier: Int
    let nationalDexNumber: String
    let localDexNumber: String
    
    let iconURL: NSURL
    let name: String
    
    let type1: PokedexTypeStruct
    let type2: PokedexTypeStruct?
}

extension PokedexEntryStruct: Transferable {
    // MARK: Initializers
    init?(transferableObject: NSDictionary) {
        guard let identifierString = transferableObject["identifier"] as? NSString,
            let nationalDexNumber = transferableObject["nationalDexNumber"] as? String,
            let localDexNumber = transferableObject["localDexNumber"] as? String,
            let iconURLString = transferableObject["iconURL"] as? String,
            let iconURL = NSURL(string: iconURLString),
            let name = transferableObject["name"] as? String,
            let type1Dict = transferableObject["type1"] as? NSDictionary,
            let type1 = PokedexTypeStruct(transferableObject: type1Dict) else {
                return nil
        }
        
        self.identifier = identifierString.integerValue
        self.nationalDexNumber = nationalDexNumber
        self.localDexNumber = localDexNumber
        
        self.iconURL = iconURL
        self.name = name
        
        self.type1 = type1
        if let type2Dict = transferableObject["type2"] as? NSDictionary,
            let type2 = PokedexTypeStruct(transferableObject: type2Dict) {
                self.type2 = type2
        } else {
            self.type2 = nil
        }
    }
    
    // MARK: Properties
    var transferableObject: NSDictionary {
        return [
            "identifier": "\(self.identifier)",
            "nationalDexNumber": self.nationalDexNumber as NSString,
            "localDexNumber": self.localDexNumber as NSString,
            
            "iconURL": self.iconURL.absoluteString as NSString,
            "name": self.name as NSString,
            
            "type1": self.type1.transferableObject as NSDictionary,
            "type2": self.type2?.transferableObject ?? "null"
        ]
    }
}