//
//  TypeEffectivenessCell.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/23/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

class TypeEffectivenessCell: CollectionCell {
    // MARK: Properties
    @IBOutlet var typeLabel: BubbleLabel!
    @IBOutlet var effectivenessLabel: UILabel!
    
    // MARK: Lifecycle
    override func setUp() {
        super.setUp()
        self.effectivenessLabel.layer.borderColor = self.typeLabel.backgroundColor?.CGColor
    }
}
