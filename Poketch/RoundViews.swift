//
//  RoundButton.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/9/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

@IBDesignable
class RoundableButton: UIButton {
    // MARK: Properties
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    // MARK: Drawing Handlers
    override func layoutSublayersOfLayer(layer: CALayer) {
        self.layer.masksToBounds = true
        super.layoutSublayersOfLayer(layer)
    }
}

class RoundButton: RoundableButton {
    // MARK: Properties
    final override var cornerRadius: CGFloat {
        get { return -1.0 }
        set {}
    }
    
    // MARK: Layout Handlers
    override func layoutSublayersOfLayer(layer: CALayer) {
        self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2.0
        super.layoutSublayersOfLayer(layer)
    }
}


class RoundImageView: UIImageView {
    // MARK: Layout Handlers
    override func layoutSublayersOfLayer(layer: CALayer) {
        self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2.0
        super.layoutSublayersOfLayer(layer)
    }
}

class RoundView: UIView {
    // MARK: Layout Handlers
    override func layoutSublayersOfLayer(layer: CALayer) {
        self.layer.cornerRadius = self.bounds.width / 2.0
        super.layoutSublayersOfLayer(layer)
    }
}