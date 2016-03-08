//
//  EntryCell.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/5/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

class EntryCell: Cell {
    // MARK: Properties
    @IBOutlet var iconBackgroundView: PolygonalView!
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var dexNumberLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var leftTypeLabel: BubbleLabel!
    @IBOutlet var rightTypeLabel: BubbleLabel!
}
