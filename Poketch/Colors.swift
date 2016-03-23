//
//  Colors.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/4/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

extension UIColor {
    // MARK: Properties
    var hexString: String {
        var components: (CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0)
        self.getRed(&components.0,
            green: &components.1,
            blue: &components.2,
            alpha: nil)
        
        return NSString(format: "#%02lX%02lX%02lX",
            lroundf(Float(components.0) * 255.0),
            lroundf(Float(components.1) * 255.0),
            lroundf(Float(components.2) * 255.0)
        ) as String
    }
    
    // MARK: Initializers
    convenience init(hexString: String) {
        let scanner = NSScanner(string: hexString)
        scanner.scanString("#", intoString: nil)
        
        var hexVal: UInt32 = 0
        scanner.scanHexInt(&hexVal)
        
        self.init(hexVal: hexVal)
    }
    
    convenience init(hexVal: UInt32) {
        self.init(red: CGFloat(((hexVal & 0xFF0000) >> 16)) / 255.0,
            green: CGFloat(((hexVal & 0x00FF00) >> 08)) / 255.0,
            blue: CGFloat(((hexVal & 0x0000FF) >> 00)) / 255.0,
            alpha: 1.0)
    }
}