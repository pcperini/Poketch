//
//  ViewController.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/8/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

// MARK: View Controller
class FrameViewController: UIViewController {
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
    
    var dataSource: FrameViewControllerDataType?
    var navigationViewController: UINavigationController? {
        return self.childViewControllers.first as? UINavigationController
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
        
        self.navigationViewController?.delegate = self
    }
    
    // MARK: Responders
    @IBAction func topBarTapGestureWasRecognized(sender: UITapGestureRecognizer?) {
        self.dataSource?.scrollView?.scrollRectToVisible(.zero, animated: true)
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

extension FrameViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        guard let dataSource = viewController as? FrameViewControllerDataType else { return }
        
        self.dataSource = dataSource
        self.dataSource?.dataDelegate = self
    }
}

extension FrameViewController: FrameViewControllerDataDelegate {
    func reloadData(animated: Bool = false) {
        self.reloadTitle(animated)
        self.reloadIndicatorImage(animated)
        self.reloadFilterButton(nil)
    }
    
    func reloadTitle(animated: Bool = false) {
        self.setTitle(self.dataSource?.title,
            animated: animated)
    }
    
    func reloadIndicatorImage(animated: Bool = false) {
        self.indicatorImageView.image = self.dataSource?.indicatorImage
        self.indicatorImageView.backgroundColor = self.dataSource?.indiactorImageBackgroundColor
        
        if let imageURL = self.dataSource?.indicatorImageURL {
            self.indicatorImageView.setImageWithURL(imageURL, placeholderImage: nil)
        }
        
        let contentsRect: CGRect
        if let areaRect = self.dataSource?.indicatorImageContentRect {
            let areaSize = self.indicatorImageView.image?.size ?? CGSize.zero
            contentsRect = CGRectNormalizedRect(areaRect, size: areaSize)
        } else {
            contentsRect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        }
        
        self.setIndicatorImageContentsRect(contentsRect, animated: animated)
    }
    
    func reloadFilterButton(swapIndex: Int? = nil) {
        self.sortFilterButtonHidden = self.dataSource?.filterButtonHidden ?? false
        
        let optionViews = self.dataSource?.filterButtonOptionViews ?? []
        if optionViews != self.sortFilterButton.optionsViews {
            self.sortFilterButton.optionsViews = optionViews
        }
        
        if let swapIndex = swapIndex {
            let selectedButton = self.dataSource?.filterButtonOptionViews[swapIndex] as? UIButton
            
            let oldTitle = self.sortFilterButton.titleForState(.Normal)
            let newTitle = selectedButton?.titleForState(.Normal)
            
            self.sortFilterButton.setTitle(newTitle, forState: .Normal)
            selectedButton?.setTitle(oldTitle, forState: .Normal)
            
            self.sortFilterButton.selected = false
        }
    }
}

// MARK: Data Source
protocol FrameViewControllerDataType {
    // MARK: Properties
    var title: String? { get }
    var scrollView: UIScrollView? { get }
    
    var indicatorImage: UIImage? { get }
    var indicatorImageURL: NSURL? { get }
    var indicatorImageContentRect: CGRect? { get }
    var indiactorImageBackgroundColor: UIColor? { get }
    
    var filterButtonHidden: Bool { get }
    var filterButtonOptionViews: [UIView] { get }
    
    var dataDelegate: FrameViewControllerDataDelegate? { get set }
}

extension FrameViewControllerDataType {
    var title: String? { return nil }
    var scrollView: UIScrollView? { return nil }
    
    var indicatorImage: UIImage? { return nil }
    var indicatorImageURL: NSURL? { return nil }
    var indicatorImageContentRect: CGRect? { return nil }
    var indiactorImageBackgroundColor: UIColor? { return nil }
    
    var filterButtonHidden: Bool { return false }
    var filterButtonOptionViews: [UIView] { return [] }
}

// MARK: Data Delegation
protocol FrameViewControllerDataDelegate {
    func reloadData(animated: Bool) -> Void
    func reloadTitle(animated: Bool) -> Void
    func reloadIndicatorImage(animated: Bool) -> Void
    func reloadFilterButton(swapIndex: Int?) -> Void
}
