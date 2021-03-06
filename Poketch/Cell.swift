//
//  Cell.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/5/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

class TableCell: UITableViewCell {
    // MARK: Properties
    override var reuseIdentifier: String? {
        return NSStringFromClass(self.dynamicType)
    }
    
    // MARK: Lifecycle
    func setUp() { }
}

class CollectionCell: UICollectionViewCell {
    // MARK: Properties
    override var reuseIdentifier: String? {
        return NSStringFromClass(self.dynamicType)
    }
    
    // MARK: Lifecycle
    func setUp() { }
}