//
//  URLExtensions.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/13/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import WatchKit

extension WKInterfaceImage {
    func setImageWithURL(url: NSURL, placeholderImage: UIImage?) {
        self.setImage(placeholderImage)
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(queue) {
            let data = NSData(contentsOfURL: url)
            dispatch_async(dispatch_get_main_queue()) {
                self.setImageData(data)
            }
        }
    }
}
