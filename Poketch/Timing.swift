//
//  Timing.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/22/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit

func dispatch_after(timeInterval: NSTimeInterval, queue: dispatch_queue_t = dispatch_get_main_queue(), block: () -> Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(timeInterval * NSTimeInterval(NSEC_PER_SEC))), queue, block)
}