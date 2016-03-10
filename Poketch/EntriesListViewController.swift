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
    // MARK: Types
    enum SortState: String {
        case Region = "NUM"
        case Alphabetical = "ABC"
        case Type = "TYPE"
    }
    
    // MARK: Properties
    var sortState: SortState = .Region {
        didSet {
            guard self.sortState != oldValue else { return }
            self.reloadData()
        }
    }
    
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
    
    var currentSectionRepresentativeEntry: PokedexEntry? {
        guard let visibleRow = self.tableView.indexPathsForVisibleRows?.middle
            else { return nil }
        
        return self.sortedAndFilteredEntries[visibleRow.section].1[visibleRow.row]
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
            button.titleLabel?.font = UIFont(name: "PokemonGB", size: 15.0)
            button.setTitleShadowColor(UIColor(white: 0.0, alpha: 0.50), forState: .Normal)
            button.titleLabel?.shadowOffset = CGSize(width: 1, height: 1)
            
            button.addTarget(self,
                action: "filterButtonWasPressed:",
                forControlEvents: .TouchUpInside)
            
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
        
        let rootVC = AppDelegate.sharedAppDelegate.rootViewController
        rootVC?.sortFilterButton.optionsViews = self.sortFilterViews
        rootVC?.scrollView = self.tableView
        
        BulbapediaClient().fetchEntries().then { (_) -> Void in
            self.reloadData()
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
    func reloadData() {
        self.sortedEntries = []
        
        let realm = try! Realm()
        let results = realm.objects(PokedexEntry)
        
        let key: (PokedexEntry) -> String
        let sort: ([(String, [PokedexEntry])]) -> [(String, [PokedexEntry])]
        
        switch self.sortState {
        case .Region:
            key = { $0.regionName }
            sort = { $0 }
        case .Alphabetical:
            key = { $0.name[$0.name.startIndex ... $0.name.startIndex] }
            sort = { (entries: [(String, [PokedexEntry])]) in
                return entries.map({ (entry: (String, [PokedexEntry])) in
                    return (entry.0, entry.1.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .OrderedAscending })
                }).sort({
                    return $0.0.localizedCaseInsensitiveCompare($1.0) == .OrderedAscending
                })
            }
            
        case .Type:
            key = { $0.type1!.name }
            sort = { (entries: [(String, [PokedexEntry])]) in
                return entries.map({ (entry: (String, [PokedexEntry])) in
                    return (entry.0, entry.1.sort { key($0) < key($1) })
                }).sort({
                    return $0.0.localizedCaseInsensitiveCompare($1.0) == .OrderedAscending
                })
            }
        }

        // Region sorting
        for entry in results {
            var found = false
            for (index, var section) in self.sortedEntries.enumerate() {
                if section.0 == key(entry) {
                    section.1 += [entry]
                    self.sortedEntries[index] = section
                    
                    found = true
                    break
                }
            }
            
            if !found {
                self.sortedEntries.append((key(entry), [entry]))
            }
        }
        
        self.sortedEntries = sort(self.sortedEntries)
        self.tableView.reloadData()
        
        self.updateTitle()
    }
    
    func updateTitle() {
        let rootVC = AppDelegate.sharedAppDelegate.rootViewController
        
        let title: String?
        let color: UIColor?
        let image: UIImage?
        
        switch self.sortState {
        case .Region:
            title = self.currentSectionRepresentativeEntry?.regionName
            color = .blackColor()
            image = UIImage(named: "Map")
        case .Alphabetical:
            title = self.currentSectionRepresentativeEntry?.name
                .substringToIndex(((self.currentSectionRepresentativeEntry?.name) ?? "").startIndex.advancedBy(1))
            color = .blackColor()
            image = nil
        case .Type:
            title = self.currentSectionRepresentativeEntry?.type1?.name
            color = self.currentSectionRepresentativeEntry?.type1?.color
            image = nil
        }
        
        rootVC?.titleLabel.text = title
        rootVC?.indicatorImageView.backgroundColor = color
        rootVC?.indicatorImageView.image = image
        
        if let regionArea = self.currentSectionRepresentativeEntry?.regionArea {
            UIView.animateWithDuration(0.3) {
                rootVC?.indicatorImageView.layer.contentsRect = CGRectNormalizedRect(regionArea, size: image?.size ?? .zero)
            }
        }
        
        rootVC?.sortFilterButtonHidden = false
    }
    
    // MARK: Responders
    @IBAction func searchTextFieldDidChange(sender: UITextField?) {
        self.tableView.reloadData()
    }
    
    func filterButtonWasPressed(sender: UIButton?) {
        let rootVC = AppDelegate.sharedAppDelegate.rootViewController
        
        let oldTitle = rootVC?.sortFilterButton.titleForState(.Normal)
        let newTitle = sender?.titleForState(.Normal)
        
        rootVC?.sortFilterButton.setTitle(newTitle, forState: .Normal)
        sender?.setTitle(oldTitle, forState: .Normal)
        
        rootVC?.sortFilterButton.selected = false
        self.sortState = SortState(rawValue: newTitle!)!
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
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let sectionTitles: [String]
        switch self.sortState {
        case .Region:
            sectionTitles = self.sortedEntries.enumerate()
                .map({ ($0.index + 1).romanNumeral })
            
        case .Alphabetical:
            sectionTitles = self.sortedEntries.enumerate()
                .map({ $0.element.0[$0.element.0.startIndex ... $0.element.0.startIndex] })
            
        case .Type:
            sectionTitles = self.sortedEntries.enumerate()
                .map({ $0.element.1[0].type1!.name })
        }
        
        return sectionTitles
    }

}

extension EntriesListViewController: UITableViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.updateTitle()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let entry = self.entryForIndexPath(indexPath)
//        self.performSegueWithIdentifier("ShowEntryDetail",
//            sender: entry)
    }
}

