//
//  BulbapediaClient.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/3/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import Foundation
import AFNetworking
import Ono
import AFOnoResponseSerializer

struct BulbapediaClient {
    // MARK: Static Properties
    private static let baseURLString = "http://bulbapedia.bulbagarden.net"
    
    // MARK: Properties
    let requestManager: AFHTTPRequestOperationManager = {
        let manager = AFHTTPRequestOperationManager(baseURL: NSURL(string: baseURLString)!)
        manager.responseSerializer = AFOnoResponseSerializer.HTMLResponseSerializer()
        return manager
    }()
}

// MARK: Extractors
extension ONOXMLElement {
    func hexColorWithCSSTag(cssTag: String) -> UIColor? {
        let attrs = self.attributes
        guard let style = attrs["style"] as? String else { return nil }
        
        let scanner = NSScanner(string: style)
        scanner.scanUpToString("\(cssTag):#", intoString: nil)
        guard scanner.scanString("\(cssTag):#", intoString: nil) else { return nil }
        
        var hexVal: UInt32 = 0
        scanner.scanHexInt(&hexVal)

        return UIColor(hexVal: hexVal)
    }
    
    func children(selector: String) -> [ONOXMLElement] {
        return (self.CSS(selector) as? NSEnumerator)?.allObjects as? [ONOXMLElement] ?? []
    }
}

extension ONOXMLDocument {
    func children(selector: String) -> [ONOXMLElement] {
        return (self.CSS(selector) as? NSEnumerator)?.allObjects as? [ONOXMLElement] ?? []
    }
}
