//
//  RoundImageView.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/9/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

class RoundImageView: UIImageView {
    // MARK: Layout Handlers
    override func layoutSublayersOfLayer(layer: CALayer) {
        self.layer.cornerRadius = self.bounds.width / 2.0
        super.layoutSublayersOfLayer(layer)
    }
}
