//
//  BubbleLabel.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/6/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

@IBDesignable
class BubbleLabel: RoundableButton {
    // MARK: Properties
    private var backgroundGradientLayer: CAGradientLayer?
    @IBInspectable var secondaryBackgroundColor: UIColor? = nil {
        didSet {
            guard let backgroundColor = self.backgroundColor,
                let secondaryBackgroundColor = self.secondaryBackgroundColor else {
                    self.backgroundGradientLayer?.removeFromSuperlayer()
                    self.backgroundGradientLayer = nil
                    return
            }
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = self.layer.bounds
            
            gradientLayer.colors = [
                backgroundColor.CGColor,
                backgroundColor.CGColor,
                secondaryBackgroundColor.CGColor,
                secondaryBackgroundColor.CGColor,
            ]
            
            gradientLayer.locations = [
                0.0, 0.5,
                0.5, 1.0
            ]
            
            gradientLayer.cornerRadius = self.layer.cornerRadius
            self.layer.insertSublayer(gradientLayer, atIndex: 0)
            
            self.backgroundGradientLayer = gradientLayer
        }
    }
    
    final override var enabled: Bool {
        get { return false }
        set {}
    }
    
    final override var buttonType: UIButtonType {
        get { return .Custom }
        set {}
    }
    
    var text: String? {
        get { return self.titleForState(.Normal) }
        set { self.setTitle(newValue, forState: .Normal) }
    }
}
