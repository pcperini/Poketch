//
//  ViewController.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/8/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

// MARK: Data Source
protocol FrameViewControllerDataType {
    // MARK: Properties
    var title: String? { get }
    
    var scrollView: UIScrollView? { get }
    
    var indicatorImage: UIImage? { get }
    var indicatorImageContentRect: CGRect? { get }
    var indiactorImageBackgroundColor: UIColor? { get }
    
    var filterButtonHidden: Bool { get }
    var filterButtonOptionViews: [UIView] { get }
}

// MARK: View Controller
class FrameViewController: UIViewController {
    // MARK: Notifications
    static let TitleNeedsUpdated = "FrameTitleNeedsUpdated"
    static let IndicatorImageNeedsUpdated = "FrameIndicatorImageNeedsUpdated"
    static let FilterButtonNeedsUpdated = "FrameFilterButtonNeedsUpdated"
    
    // MARK: User Info
    static let UpdateAnimatedUserInfoKey = "Animated"
    static let FilterButtonSwapIndexUserInfoKey = "FilterButtonSwapIndex"
    
    // MARK: Properties
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleLabelHeightConstraint: NSLayoutConstraint!
    final override var title: String? {
        get { return self.titleLabel.text }
        set { self.titleLabel.text = newValue }
    }
    
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
    
    var navigationViewController: UINavigationController? {
        return self.childViewControllers.first as? UINavigationController
    }
    
    var dataSource: FrameViewControllerDataType? {
        return self.navigationViewController?.topViewController as? FrameViewControllerDataType
    }
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "titleNeedsUpdated:",
            name: FrameViewController.TitleNeedsUpdated,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "indicatorImageNeedsUpdated:",
            name: FrameViewController.IndicatorImageNeedsUpdated,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "filterButtonNeedsUpdated:",
            name: FrameViewController.FilterButtonNeedsUpdated,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Responders
    @IBAction func topBarTapGestureWasRecognized(sender: UITapGestureRecognizer?) {
        self.dataSource?.scrollView?.scrollRectToVisible(.zero, animated: true)
    }
    
    func titleNeedsUpdated(notification: NSNotification?) {
        let animated = (notification?.userInfo?[FrameViewController.UpdateAnimatedUserInfoKey] as? Bool)
            ?? false
        
        self.setTitle(self.dataSource?.title,
            animated: animated)
    }
    
    func indicatorImageNeedsUpdated(notification: NSNotification?) {
        self.indicatorImageView.image = self.dataSource?.indicatorImage
        self.indicatorImageView.backgroundColor = self.dataSource?.indiactorImageBackgroundColor
        
        let animated = (notification?.userInfo?[FrameViewController.UpdateAnimatedUserInfoKey] as? Bool)
            ?? false
        
        let areaRect = self.dataSource?.indicatorImageContentRect
            ?? CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        let areaSize = self.indicatorImageView.image?.size ?? CGSize.zero
        
        let contentsRect = CGRectNormalizedRect(areaRect, size: areaSize)
        self.setIndicatorImageContentsRect(contentsRect, animated: animated)
    }
    
    func filterButtonNeedsUpdated(notification: NSNotification?) {
        self.sortFilterButton.hidden = self.dataSource?.filterButtonHidden ?? false
        
        let optionViews = self.dataSource?.filterButtonOptionViews ?? []
        if optionViews != self.sortFilterButton.optionsViews {
            self.sortFilterButton.optionsViews = optionViews
        }
        
        if let swapIndex = notification?.userInfo?[FrameViewController.FilterButtonSwapIndexUserInfoKey] as? Int {
            let selectedButton = self.dataSource?.filterButtonOptionViews[swapIndex] as? UIButton
            
            let oldTitle = self.sortFilterButton.titleForState(.Normal)
            let newTitle = selectedButton?.titleForState(.Normal)
            
            self.sortFilterButton.setTitle(newTitle, forState: .Normal)
            selectedButton?.setTitle(oldTitle, forState: .Normal)
            
            self.sortFilterButton.selected = false
        }
    }
    
    // MARK: Mutators
    func setTitle(title: String?, animated: Bool) {
        guard title != self.title else { return }
        guard animated else {
            self.title = title
            return
        }
        
        UIView.animateWithDuration(0.3, animations: {
            self.titleLabelHeightConstraint.constant = 0
            self.titleLabelHeightConstraint.priority = UILayoutPriorityDefaultHigh
            self.titleLabel.superview?.layoutIfNeeded()
            
        }, completion: { (_) in
            self.titleLabel.text = title
            
            UIView.animateWithDuration(0.3) {
                self.titleLabelHeightConstraint.priority = UILayoutPriorityDefaultLow
                self.titleLabel.superview?.layoutIfNeeded()
            }
        })
    }
    
    func setIndicatorImageContentsRect(contentsRect: CGRect, animated: Bool) {
        guard contentsRect != self.indicatorImageView.layer.contentsRect else { return }
        guard animated else {
            self.indicatorImageView.layer.contentsRect = contentsRect
            return
        }
        
        UIView.animateWithDuration(0.3) {
            self.indicatorImageView.layer.contentsRect = contentsRect
        }
    }
}
