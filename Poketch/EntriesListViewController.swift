//
//  ViewController.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/3/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import RealmSwift
import QuartzCore

@IBDesignable
class EntriesListViewController: UIViewController {
    // MARK: Properties
    var sortedEntries: [(String, [PokedexEntry])] = []
    var sortedAndFilteredEntries: [(String, [PokedexEntry])] {
        if let searchText = self.searchTextField.text where !searchText.isEmpty {
            return self.sortedEntries.map { (element: (String, [PokedexEntry])) in
                return (element.0, element.1.filter({
                    $0.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
                }))
            }
        }
        
        return self.sortedEntries
    }
    
    var allEntries: [PokedexEntry] {
        return self.sortedEntries.reduce([]) { $0.0 + $0.1.1 }
    }
    
    var currentSectionTitle: String? {
        guard let visibleRow = self.tableView.indexPathsForVisibleRows?.middle
            else { return nil }
        
        return self.sortedAndFilteredEntries[visibleRow.section].0
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBInspectable var filterButtonColor: UIColor?
    @IBOutlet var searchTextFieldContainer: UIView!
    @IBOutlet var searchTextField: UITextField!
    private var sortFilterViews: [UIView] {
        let buttonWithTitle = { (title: String) -> RoundableButton in
            let button = RoundableButton()
            button.cornerRadius = 4.0
            button.backgroundColor = self.filterButtonColor
            
            button.setTitle(title, forState: .Normal)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.font = UIFont(name: "PokemonGB", size: 15.0)
            button.setTitleShadowColor(UIColor(white: 0.0, alpha: 0.50), forState: .Normal)
            button.titleLabel?.shadowOffset = CGSize(width: 1, height: 1)
            
            return button
        }
        
        return [
            buttonWithTitle("ABC"),
            buttonWithTitle("TYPE"),
            self.searchTextFieldContainer
        ]
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.tableView.contentInset = UIEdgeInsets(top: 30.0, left: 0, bottom: 79.0, right: 0)
        self.tableView.sectionIndexBackgroundColor = UIColor.clearColor()
        
        self.searchTextFieldContainer.layer.borderColor = self.filterButtonColor?.CGColor
        
        AppDelegate.sharedAppDelegate.rootViewController?.sortFilterButton.optionsViews = self.sortFilterViews
        
        BulbapediaClient().fetchEntries().then { (_) -> Void in
            self.reloadData()
            self.updateTitle()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateTitle()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "ShowEntryDetail":
            (segue.destinationViewController as? EntryViewController)?.entry = (sender as? PokedexEntry)
        
        default:
            break
        }
    }
    
    // MARK: Accessors
    private var maxWidthNameLabelFont: UIFont?
    private func maxWidthNameLabelFont(inCell cell: EntryCell) -> UIFont? {
        if self.maxWidthNameLabelFont == nil {
            let stringBoundingRect = { (string: String, font: UIFont?) -> CGRect in
                let font = font ?? UIFont.systemFontOfSize(10.0)
                return (string as NSString).boundingRectWithSize(CGRectInfinite.size,
                    options: .UsesLineFragmentOrigin,
                    attributes: [NSFontAttributeName: font],
                    context: nil)
            }
            
            var bounds = cell.bounds
            bounds.size.width = self.tableView.bounds.width - self.tableView.subviews.last!.bounds.width
            cell.bounds = bounds
            cell.layoutIfNeeded()
            
            guard let maxWidthName = self.allEntries
                .sort({ stringBoundingRect($0.0.name, nil).width > stringBoundingRect($0.1.name, nil).width })
                .first?.name else { return nil }

            var fontSize = cell.nameLabel.font.pointSize
            repeat {
                let font = cell.nameLabel.font.fontWithSize(fontSize)
                let textRect = stringBoundingRect(maxWidthName, font)
                if CGRectContainsRect(cell.nameLabel.bounds, textRect) {
                    break
                }
                
                fontSize -= 1
            } while fontSize > 0

            self.maxWidthNameLabelFont = cell.nameLabel.font.fontWithSize(fontSize)
        }
        
        return self.maxWidthNameLabelFont
    }
    
    private func entryForIndexPath(indexPath: NSIndexPath) -> PokedexEntry {
        return self.sortedAndFilteredEntries[indexPath.section].1[indexPath.row]
    }
    
    // MARK: Mutators
    func reloadData(modifier: (Results<PokedexEntry>) -> Results<PokedexEntry> = { $0 }) {
        let realm = try! Realm()
        let results = modifier(realm.objects(PokedexEntry))
        
        // Region sorting
        for entry in results {
            var found = false
            for (index, var section) in self.sortedAndFilteredEntries.enumerate() {
                if section.0 == entry.regionName {
                    section.1 += [entry]
                    self.sortedEntries[index] = section
                    
                    found = true
                    break
                }
            }
            
            if !found {
                self.sortedEntries.append((entry.regionName, [entry]))
            }
        }
        
        
        self.tableView.reloadData()
    }
    
    func updateTitle() {
        let rootVC = AppDelegate.sharedAppDelegate.rootViewController
        rootVC?.titleLabel.text = self.currentSectionTitle
        
        print(self.currentSectionTitle)
        rootVC?.regionImageView.image = UIImage(named: self.currentSectionTitle ?? "")
    }
    
    // MARK: Responders
    @IBAction func searchTextFieldDidChange(sender: UITextField?) {
        self.tableView.reloadData()
    }
}

extension EntriesListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sortedAndFilteredEntries.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedAndFilteredEntries[section].1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let entry = self.entryForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellOfType(EntryCell)!
        
        cell.iconBackgroundView.borderColor = entry.type1!.color
        cell.iconImageView.setImageWithURL(entry.iconURL, placeholderImage: nil)
        
        cell.dexNumberLabel.text = entry.nationalDexNumber
        
        cell.nameLabel.font = self.maxWidthNameLabelFont(inCell: cell)
        cell.nameLabel.text = entry.name
        
        cell.leftTypeLabel.backgroundColor = entry.type1!.color
        cell.leftTypeLabel.text = entry.type1!.abbreviatedName
        
        if let type2 = entry.type2 {
            cell.rightTypeLabel.backgroundColor = type2.color
            cell.rightTypeLabel.text = type2.abbreviatedName
            
            cell.rightTypeLabel.hidden = false
        } else {
            cell.rightTypeLabel.hidden = true
        }

        return cell
    }
    
    private static let padLength = 2
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var sectionTitles = self.sortedAndFilteredEntries.enumerate().map { ($0.index + 1).romanNumeral }
        
        for _ in 0 ..< EntriesListViewController.padLength {
            let sectionTitlesCopy = sectionTitles
            sectionTitlesCopy.enumerate().forEach {
                sectionTitles.insert("\n", atIndex: $0.index + (sectionTitles.count - sectionTitlesCopy.count))
            }
        }
        
        return sectionTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index / Int(pow(Float(EntriesListViewController.padLength), 2))
    }
}

extension EntriesListViewController: UITableViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.updateTitle()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let entry = self.entryForIndexPath(indexPath)
        self.performSegueWithIdentifier("ShowEntryDetail",
            sender: entry)
    }
}

