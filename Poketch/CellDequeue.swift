//
//  CellDequeue.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/5/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCellOfType<CellType: TableCell>(cellType: CellType.Type) -> CellType? {
        let cell = self.dequeueReusableCellWithIdentifier(NSStringFromClass(cellType)) as? CellType
        cell?.setUp()
        return cell
    }
}

extension UICollectionView {
    func dequeueReusableCellOfType<CellType: CollectionCell>(cellType: CellType.Type, forIndexPath indexPath: NSIndexPath) -> CellType? {
        let cell = self.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(cellType),
            forIndexPath: indexPath) as? CellType
        cell?.setUp()
        return cell
    }
}