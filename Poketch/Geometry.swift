//
//  Geometry.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/10/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

func CGRectNormalizedRect(rect: CGRect, size: CGSize) -> CGRect {
    return CGRect(x: rect.origin.x / size.width,
        y: rect.origin.y / size.height,
        width: rect.size.width / size.width,
        height: rect.size.height / size.height)
}