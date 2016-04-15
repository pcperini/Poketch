//
//  EntryViewController.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/8/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import APNGKit

class EntryViewController: UIViewController {
    // MARK: Properties
    var entry: PokedexEntry! { didSet { self.updateEntry() } }
    private var weakTypes: [PokedexTypeEffectiveness] {
        return self.entry.details?.typeEffectivenesses
            .filter("effectiveness > 1.0")
            .map { $0 }
            .sort { $0.0.effectiveness > $0.1.effectiveness } ?? []
    }
    
    private var resistantTypes: [PokedexTypeEffectiveness] {
        return self.entry.details?.typeEffectivenesses
            .filter("effectiveness < 1.0")
            .map { $0 }
            .sort { $0.0.effectiveness < $0.1.effectiveness } ?? []
    }
    
    weak var dataDelegate: FrameViewControllerDataDelegate?
    let statMax: Float = 200.0
    
    @IBOutlet var hexView: PolygonalView!
    @IBOutlet var animatedImageView: APNGImageView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nationalDexLabel: UILabel!
    @IBOutlet var leftTypeLabel: BubbleLabel!
    @IBOutlet var rightTypeLabel: BubbleLabel!
    
    @IBOutlet var hpBar: UIProgressView!
    @IBOutlet var attackBar: UIProgressView!
    @IBOutlet var defenseBar: UIProgressView!
    @IBOutlet var spAttackBar: UIProgressView!
    @IBOutlet var spDefenseBar: UIProgressView!
    @IBOutlet var speedBar: UIProgressView!
    
    var headerView: UIView?
    
    private lazy var statCouplings: [UIProgressView: () -> Float] = [
        self.hpBar: { Float(self.entry.details!.baseHP) / self.statMax },
        self.attackBar: { Float(self.entry.details!.baseAttack) / self.statMax },
        self.defenseBar: { Float(self.entry.details!.baseDefense) / self.statMax },
        self.spAttackBar: { Float(self.entry.details!.baseSpAttack) / self.statMax },
        self.spDefenseBar: { Float(self.entry.details!.baseSpDefense) / self.statMax },
        self.speedBar: { Float(self.entry.details!.baseSpeed) / self.statMax }
    ]
    
    @IBOutlet var weakTypesCollectionView: UICollectionView!
    @IBOutlet var weakTypesCollectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var resistantTypesCollectionView: UICollectionView!
    @IBOutlet var resistantTypesCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private var animatedImageURL: NSURL? {
        didSet {
            self.animatedImageView?.stopAnimating()
            self.animatedImageView?.image = nil
            
            guard let animatedImageURL = self.animatedImageURL else { return }
            guard !animatedImageURL.absoluteString.isEmpty else { return }
            
            guard let animatedImageView = self.animatedImageView else { return }
            guard let imageView = self.imageView else { return }
            
            let data = NSData(contentsOfURL: animatedImageURL)!
            if let image = APNGImage(data: data, scale: 2) where image.duration != Double.infinity {
                animatedImageView.hidden = false
                imageView.hidden = true
                
                animatedImageView.image = image
                animatedImageView.startAnimating()
            } else {
                animatedImageView.hidden = true
                imageView.hidden = false
                
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateEntry()
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        dispatch_after(0.5) {
            self.dataDelegate?.reloadData(true)
        }
    }
    
    // MARK: Mutators
    private func updateEntry() {
        guard let _ = self.viewIfLoaded else { return }
        
        self.hexView.borderColor = self.entry.type1!.color
        self.nameLabel.text = self.entry.name
        self.nationalDexLabel.text = self.entry.nationalDexNumber
        
        var type1Label: BubbleLabel? = self.leftTypeLabel
        var type2Label: BubbleLabel? = self.rightTypeLabel
        
        type1Label?.hidden = false
        type2Label?.hidden = false
        
        if self.entry.type2 == nil {
            type1Label = self.rightTypeLabel
            type2Label = nil
            
            self.leftTypeLabel.hidden = true
        }
        
        type1Label?.text = self.entry.type1?.abbreviatedName
        type1Label?.backgroundColor = self.entry.type1?.color
        
        type2Label?.text = self.entry.type2?.abbreviatedName
        type2Label?.backgroundColor = self.entry?.type2?.color
        
        if let details = self.entry.details {
            self.animatedImageURL = details.detailImageURL
            
            dispatch_after(0.5) {
                self.reloadCollectionData(true)
                self.statCouplings.forEach { $0.setProgress($1(), animated: true) }
            }
        } else {
            BulbapediaClient().fetchDetailsForEntry(self.entry) { (details: PokedexEntryDetails, _) in
                self.updateEntry()
            }
        }
    }
    
    func reloadCollectionData(animated: Bool = false) {
        let collectionViews = [
            self.weakTypesCollectionView,
            self.resistantTypesCollectionView
        ]
        
        collectionViews.forEach {
            $0.reloadData()
            self.updateNumberOfLinesForCollectionView($0, animated: animated)
        }
    }
    
    func updateNumberOfLinesForCollectionView(collectionView: UICollectionView, animated: Bool = false) {
        let constraint: NSLayoutConstraint
        switch collectionView {
        case self.weakTypesCollectionView:
            constraint = self.weakTypesCollectionViewHeightConstraint
        case self.resistantTypesCollectionView:
            constraint = self.resistantTypesCollectionViewHeightConstraint
        default:
            return
        }
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let numberOfItemsPerLine = floor(collectionView.bounds.width / (flowLayout.itemSize.width + (flowLayout.minimumInteritemSpacing * 2.0)))
        let numberOfLines = ceil(CGFloat(collectionView.numberOfItemsInSection(0)) / numberOfItemsPerLine)
        
        let lineHeight = flowLayout.itemSize.height + (flowLayout.minimumLineSpacing * 1.25)
        constraint.constant = lineHeight * CGFloat(numberOfLines)
            + collectionView.contentInset.top
            + collectionView.contentInset.bottom
        
        if animated {
            UIView.animateWithDuration(0.33) {
                flowLayout.invalidateLayout()
                self.view.layoutIfNeeded()
            }
        } else {
            flowLayout.invalidateLayout()
        }
    }
    
    // MARK: Responders
    @IBAction func doneButtonWasPressed(sender: UIButton?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension EntryViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.weakTypesCollectionView:
            return self.weakTypes.count
        case self.resistantTypesCollectionView:
            return self.resistantTypes.count
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellOfType(TypeEffectivenessCell.self, forIndexPath: indexPath)!

        let effectiveness: PokedexTypeEffectiveness
        switch collectionView {
        case self.weakTypesCollectionView:
            effectiveness = self.weakTypes[indexPath.row]
        case self.resistantTypesCollectionView:
            effectiveness = self.resistantTypes[indexPath.row]
        default:
            return cell
        }
        
        cell.typeLabel.text = effectiveness.type.abbreviatedName
        cell.typeLabel.backgroundColor = effectiveness.type.color
        
        cell.effectivenessLabel.text = "\(effectiveness.effectiveness.fraction)x "
        
        cell.setUp()
        return cell
    }
}

extension EntryViewController: FrameViewControllerDataType {
    // MARK: Properties
    override var title: String? {
        get { return self.entry.name }
        set {}
    }
    
    var indicatorAudioFileName: String? {
        return NSString(format: "%03d", self.entry.identifier) as String
    }
    
    var indicatorAudioTintColor: UIColor? {
        return self.entry.type1!.color
    }
    
    var filterButtonHidden: Bool {
        return true
    }
}