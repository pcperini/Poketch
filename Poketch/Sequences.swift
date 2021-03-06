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

extension _ArrayType where Generator.Element: Equatable {
    public func unique() -> Self {
        var arrayCopy = self
        arrayCopy.uniqueInPlace()
        return arrayCopy
    }
    
    mutating public func uniqueInPlace() {
        var seen: [Generator.Element] = []
        var index = 0
        for element in self {
            if seen.contains(element) {
                self.removeAtIndex(index)
            } else {
                seen.append(element)
                index += 1
            }
        }
    }
}

extension CollectionType {
    public var middle: Generator.Element? {
        guard self.count > 0 else { return nil }
        guard self.count > 2 else { return self[self.startIndex] }
        return self[self.startIndex.advancedBy(self.count / 2)]
    }
}