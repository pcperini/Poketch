//
//  PokedexTypeEffectiveness.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/21/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import RealmSwift

class PokedexTypeEffectiveness: Object {
    // MARK: Properties
    dynamic var type: PokedexType!
    dynamic var effectiveness: Float = 1.0
}
