//
//  Sequences.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/6/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import Foundation

extension SequenceType where Generator.Element: Hashable {
    func frequencies() -> [(Generator.Element,Int)] {
        
        var frequency: [Generator.Element:Int] = [:]
        
        for x in self {
            frequency[x] = (frequency[x] ?? 0) + 1
        }
        
        return frequency.sort { $0.1 > $1.1 }
    }
}
