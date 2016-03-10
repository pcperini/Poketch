//
//  ToggleView.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/8/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import PromiseKit

class ExternalHitView: UIView {
    // MARK: Hit Testing
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        for view in self.subviews where !view.hidden && view.userInteractionEnabled {
            let subpoint = view.convertPoint(point, fromView: self)
            if CGRectContainsPoint(view.bounds, subpoint) {
                return view.hitTest(subpoint, withEvent: event)
            } else if let optionButton = view as? OptionButton where CGRectContainsPoint(optionButton.totalBounds, subpoint) {
                return optionButton.hitTest(subpoint, withEvent: event)
            }
        }
        
        return super.hitTest(point, withEvent: event)
    }
}

class ToggleButton: UIButton {
    // MARK: Touches
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.selected = !self.selected
        super.touchesEnded(touches, withEvent: event)
    }
}

@IBDesignable
class OptionButton: ToggleButton {
    // MARK: Properties
    @IBInspectable var optionsOffset: CGFloat = 10.0
    @IBInspectable var optionsDirection: CGFloat = -1.0
    @IBInspectable var optionsAnimationDuration: CGFloat = 0.3
    
    private var totalBounds: CGRect {
        return self.optionsViews.reduce(self.bounds) { CGRectUnion($0.0, $0.1.frame) }
    }
    
    private var yConstraints: [NSLayoutConstraint] = []
    var optionsViews: [UIView] = [] {
        willSet {
            self.optionsViews.forEach { $0.removeFromSuperview() }
        }
        
        didSet {
            self.yConstraints = []
            self.optionsViews.enumerate().forEach {
                $0.element.translatesAutoresizingMaskIntoConstraints = false
                $0.element.hidden = true
                self.addSubview($0.element)
                
                self.setEqualAttributes(.Width, toView: $0.element)
                self.setEqualAttributes(.Height, toView: $0.element)
                self.setEqualAttributes(.CenterX, toView: $0.element)
                
                let previousView = $0.index == 0 ? self : self.optionsViews[$0.index - 1]
                self.yConstraints.append(NSLayoutConstraint(item: $0.element,
                    attribute: .Bottom,
                    relatedBy: .Equal,
                    toItem: previousView,
                    attribute: .Top,
                    multiplier: 1.0,
                    constant: self.bounds.height))

                self.addConstraint(self.yConstraints.last!)
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            if self.selected {
                self.showOptions()
            } else {
                self.hideOptions()
            }
        }
    }
    
    // MARK: Options Display Handlers
    private func showOptions() {
        self.yConstraints.forEach { $0.constant = self.optionsOffset * self.optionsDirection }
        self.optionsViews.forEach {
            $0.alpha = 0
            $0.hidden = false
        }
        
        self.optionsViews.enumerate().forEach { (option) in
            UIView.animateWithDuration(NSTimeInterval(self.optionsAnimationDuration),
                delay: 0,
                options: UIViewAnimationOptions(),
                animations: {
                    option.element.alpha = 1
                    option.element.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    private func hideOptions() {
        self.optionsViews.forEach {
            $0.resignFirstResponder()
            $0.subviews.forEach { $0.resignFirstResponder() }
        }
        
        self.yConstraints.forEach { $0.constant = self.bounds.height }
        
        self.optionsViews.enumerate().forEach { (option) in
            UIView.animateWithDuration(NSTimeInterval(self.optionsAnimationDuration),
                delay: 0,
                options: UIViewAnimationOptions(),
                animations: {
                    option.element.layoutIfNeeded()
                    option.element.alpha = 0
                }, completion: { (_) in
                    option.element.hidden = true
                    option.element.alpha = 1
                })
        }
    }
    
    // MARK: Hit Testing
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        for view in self.subviews {
            let subpoint = view.convertPoint(point, fromView: self)
            if CGRectContainsPoint(view.bounds, subpoint) && !view.hidden {
                let subpoint = view.convertPoint(point, fromView: self)
                return view.hitTest(subpoint, withEvent: event) ?? view
            }
        }
        
        return super.hitTest(point, withEvent: event)
    }
}

private extension UIView {
    // MARK: Constraint Improvements
    func setEqualAttributes(attribute: NSLayoutAttribute, toView view: UIView) {
        self.addConstraint(NSLayoutConstraint(item: view,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: self,
            attribute: attribute,
            multiplier: 1.0,
            constant: 0.0))
    }
}