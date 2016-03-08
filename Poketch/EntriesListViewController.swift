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
    var entries: Results<PokedexEntry>?
    var currentRegion: String? {
        guard let visibleRows = self.tableView.indexPathsForVisibleRows?.map({ $0.row })
            else { return nil }
        
        let frequencies = self.entries?[visibleRows.first! ..< visibleRows.last!]
            .map({ $0.regionName })
            .frequencies()
        return frequencies?.first?.0
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: 0, right: 0)
        
        BulbapediaClient().fetchEntries().then { (_) -> Void in
            self.reloadData()
            self.titleLabel.text = self.currentRegion
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
            bounds.size.width = self.tableView.bounds.width
            cell.bounds = bounds
            cell.layoutIfNeeded()
            
            guard let maxWidthName = self.entries?
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
    
    // MARK: Mutators
    func reloadData(modifier: (Results<PokedexEntry>) -> Results<PokedexEntry> = { $0 }) {
        let realm = try! Realm()
        self.entries = modifier(realm.objects(PokedexEntry))
        self.tableView.reloadData()
    }
}

extension EntriesListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let entry = self.entries![indexPath.row]
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
}

extension EntriesListViewController: UITableViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.titleLabel.text = self.currentRegion
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let entry = self.entries![indexPath.row]
        UIApplication.sharedApplication().openURL(entry.sourceURL)
    }
}

