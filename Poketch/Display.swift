//
//  Display.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/7/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import Foundation

extension Int {
    var romanNumeral: String {
        let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let arabicValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        
        var romanValue = ""
        var startingValue = self
        
        for (index, romanChar) in romanValues.enumerate() {
            let arabicValue = arabicValues[index]
            let div = startingValue / arabicValue
            
            if (div > 0) {
                for _ in 0..<div {
                    romanValue += romanChar
                }
                
                startingValue -= arabicValue * div
            }
        }
        
        return romanValue
    }
}

extension Float {
    var fraction: String {
        switch self {
        case 0.25:
            return "1/4"
        case 0.5:
            return "1/2"
        default:
            return "\(Int(self))"
        }
    }
}
