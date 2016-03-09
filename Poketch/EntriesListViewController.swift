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

class EntriesListViewController: UIViewController {
    // MARK: Properties
    var sortedEntries: [(String, [PokedexEntry])] = []
    var allEntries: [PokedexEntry] {
        return self.sortedEntries.reduce([]) { $0.0 + $0.1.1 }
    }
    
    var currentSectionTitle: String? {
        guard let visibleRow = self.tableView.indexPathsForVisibleRows?.map({ $0.section }).first
            else { return nil }
        
        return self.sortedEntries[visibleRow].0
    }
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.tableView.contentInset = UIEdgeInsets(top: 30.0, left: 0, bottom: 79.0, right: 0)
        
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
            bounds.size.width = self.tableView.bounds.width - 40 // (UITableViewIndex)
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
        return self.sortedEntries[indexPath.section].1[indexPath.row]
    }
    
    // MARK: Mutators
    func reloadData(modifier: (Results<PokedexEntry>) -> Results<PokedexEntry> = { $0 }) {
        let realm = try! Realm()
        let results = modifier(realm.objects(PokedexEntry))
        
        // Region sorting
        for entry in results {
            var found = false
            for (index, var section) in self.sortedEntries.enumerate() {
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
        AppDelegate.sharedAppDelegate.rootViewController?.titleLabel.text = self.currentSectionTitle
    }
}

extension EntriesListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sortedEntries.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedEntries[section].1.count
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
        } else {
            cell.rightTypeLabel.hidden = true
        }

        return cell
    }
    
    private static let padLength = 2
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var sectionTitles = self.sortedEntries.enumerate().map { ($0.index + 1).romanNumeral }
        
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

