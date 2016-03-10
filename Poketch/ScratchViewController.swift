//
//  ScratchViewController.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/8/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

class ScratchViewController: UIViewController {
    @IBOutlet var optionButton: OptionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionButton.optionsViews = (0 ..< 7).map { (_) in
            UIButton(type: .ContactAdd)
        }
    }
}
