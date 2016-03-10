//
//  ViewController.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/8/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: Properties
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var sortFilterButton: OptionButton!
    
    @IBOutlet var regionImageView: UIImageView!
    @IBOutlet var regionImageGlossView: UIView!
    
    var scrollView: UIScrollView?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.regionImageGlossView.bounds
        gradientLayer.colors = [
            UIColor(white: 1.0, alpha: 0.9).CGColor,
            UIColor(white: 1.0, alpha: 0.0).CGColor
        ]
        
        self.regionImageGlossView.layer.addSublayer(gradientLayer)
        self.regionImageView.superview?.layer.borderColor = UIColor(hexString: "#2875A8").CGColor
    }
    
    // MARK: Responders
    @IBAction func topBarTapGestureWasRecognized(sender: UITapGestureRecognizer?) {
        self.scrollView?.scrollRectToVisible(.zero, animated: true)
    }
}
