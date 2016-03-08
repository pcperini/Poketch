//
//  _Extensions.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/5/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

extension UITableView {
    public func dequeueReusableCellOfType<CellType: UITableViewCell>(cellType: CellType.Type) -> CellType? {
        return self.dequeueReusableCellWithIdentifier(NSStringFromClass(cellType)) as? CellType
    }
}
