//
//  Transferable.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/16/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import Foundation

protocol Transferable {
    // MARK: Initializers
    init?(transferableObject: NSDictionary)
    
    // MARK: Properties
    var transferableObject: NSDictionary { get }
}

protocol TransferableStructConvertible {
    // MARK: Types
    typealias StructType: Transferable
    
    // MARK: Properties
    var structValue: StructType { get }
}