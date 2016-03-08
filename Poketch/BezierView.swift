//
//  BezierView.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/5/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

@IBDesignable
class BezierView: UIView {
    // MARK: Properties
    private var backgroundLayer: CAShapeLayer?
    private var borderLayer: CAShapeLayer?
    
    lazy var bezierPath: UIBezierPath = self.initialBezierPath()
    
    @IBInspectable var pathColor: UIColor = UIColor.whiteColor() { didSet { self.updateShapeLayer() } }
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() { didSet { self.updateShapeLayer() } }
    
    // MARK: Accessors
    private func initialBezierPath() -> UIBezierPath {
        return UIBezierPath(rect: self.bounds)
    }
    
    // MARK: Mutators
    private func updateShapeLayer() {
        if self.backgroundLayer == nil {
            self.backgroundLayer = CAShapeLayer()
            self.layer.insertSublayer(self.backgroundLayer!, atIndex: 0)
        }
        
        self.backgroundLayer?.path = self.bezierPath.CGPath
        self.backgroundLayer?.lineWidth = self.bezierPath.lineWidth
        
        self.backgroundLayer?.fillColor = self.pathColor.CGColor
        self.backgroundLayer?.strokeColor = self.borderColor.CGColor
    }
}


@IBDesignable
class PolygonalView: BezierView {
    // MARK: Properties
    private var needsNewBezierPath: Bool = false
    
    @IBInspectable var borderWidth: CGFloat = 0.0 { didSet { self.updateShapeLayer() } }
    
    @IBInspectable var sides: Int = 0 {
        didSet {
            self.needsNewBezierPath = true
            self.updateShapeLayer()
        }
    }
    
    @IBInspectable var rotation: CGFloat = 0.0 {
        didSet {
            self.needsNewBezierPath = true
            self.updateShapeLayer()
        }
    }
    
    // MARK: Accessors
    private final override func initialBezierPath() -> UIBezierPath {
        let path = UIBezierPath(polygonWithNumberOfSides: self.sides,
            inRect: CGRectInset(self.bounds, 2.0, 2.0))!
        
        let rotation = CGFloat(self.rotation) * CGFloat(M_PI) / 180.0
        let center = CGPoint(x: CGRectGetMidX(self.bounds), y: CGRectGetMidY(self.bounds))
        
        var transform = CGAffineTransformMakeTranslation(center.x, center.y)
        transform = CGAffineTransformRotate(transform, rotation)
        transform = CGAffineTransformTranslate(transform, -center.x, -center.y)
        path.applyTransform(transform)
        
        return path
    }
    
    // MARK: Mutators
    private override func updateShapeLayer() {
        if self.needsNewBezierPath {
            self.needsNewBezierPath = false
            self.bezierPath = self.initialBezierPath()
        }
        
        self.bezierPath.lineWidth = self.borderWidth
        super.updateShapeLayer()
    }
}

extension UIBezierPath {
    // MARK: Initializers
    convenience init?(polygonWithNumberOfSides sides: Int, inRect rect: CGRect) {
        guard sides >= 3 else { return nil }
        
        let xRadius = rect.width / 2.0
        let yRadius = rect.height / 2.0
        
        let center = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
        self.init()
        
        self.moveToPoint(CGPoint(x: center.x + xRadius, y: center.y))
        for side in 0 ..< sides {
            let theta = Float(2.0 * CGFloat(M_PI) / CGFloat(sides) * CGFloat(side))
            let coordinate = CGPoint(x: center.x + xRadius * CGFloat(cosf(theta)),
                y: center.y + yRadius * CGFloat(sinf(theta)))
            
            self.addLineToPoint(coordinate)
        }
        
        self.closePath()
    }
}