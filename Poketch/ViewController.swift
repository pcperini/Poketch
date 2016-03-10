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
    
    @IBOutlet var sortFilterButtonContainer: UIView!
    @IBOutlet var sortFilterButton: OptionButton!
    var sortFilterButtonHidden: Bool {
        get { return self.sortFilterButton.hidden && self.sortFilterButtonContainer.hidden }
        set {
            self.sortFilterButton.hidden = newValue
            self.sortFilterButtonContainer.hidden = newValue
        }
    }
    
    @IBOutlet var indicatorImageView: UIImageView!
    @IBOutlet var indicatorImageGlossView: UIView!
    
    var scrollView: UIScrollView?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.indicatorImageGlossView.bounds
        gradientLayer.colors = [
            UIColor(white: 1.0, alpha: 0.7).CGColor,
            UIColor(white: 1.0, alpha: 0.0).CGColor
        ]
        
        self.indicatorImageGlossView.layer.addSublayer(gradientLayer)
        self.indicatorImageView.superview?.layer.borderColor = UIColor(hexString: "#2875A8").CGColor
    }
    
    // MARK: Responders
    @IBAction func topBarTapGestureWasRecognized(sender: UITapGestureRecognizer?) {
        self.scrollView?.scrollRectToVisible(.zero, animated: true)
    }
}
