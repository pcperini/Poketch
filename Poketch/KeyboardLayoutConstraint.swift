//
//  KeyboardLayoutConstraint.swift
//  MiseEnPlace
//
//  Inspired by James Tang's work with Spring.
//
//  Created by PATRICK PERINI on 9/12/15.
//  Copyright © 2015 pcperini. All rights reserved.
//

import UIKit

public class KeyboardLayoutConstraint: NSLayoutConstraint {
    // MARK: Properties
    private var offset: CGFloat = 0.0
    private var keyboardHeight: CGFloat = 0.0 {
        didSet {
            self.constant = self.offset + self.keyboardHeight
        }
    }
    
    // MARK: Mutators
    private func updateKeyboardHeight(userInfo: NSDictionary) {
        if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let frame = frameValue.CGRectValue()
            self.keyboardHeight = frame.height
        } else {
            self.keyboardHeight = 0.0
        }
        
        if let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                let options = UIViewAnimationOptions(rawValue: curveValue.unsignedLongValue)
                let duration = NSTimeInterval(durationValue.doubleValue)
                
                UIView.animateWithDuration(duration, delay: 0, options: options, animations: { () -> Void in
                    UIApplication.sharedApplication().keyWindow?.layoutIfNeeded()
                }, completion: nil)
        }
    }

    // MARK: Initializers
    override init() {
        super.init()
        self.setup()
    }
    
    // MARK: Lifecycle
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func setup() {
        self.offset = self.constant
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(KeyboardLayoutConstraint.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(KeyboardLayoutConstraint.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Responders
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        self.updateKeyboardHeight(userInfo)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard var userInfo = notification.userInfo else { return }
        userInfo.removeValueForKey(UIKeyboardFrameEndUserInfoKey)
        
        self.updateKeyboardHeight(userInfo)
    }
}
