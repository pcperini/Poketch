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
    private let requestQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        
        queue.underlyingQueue = dispatch_queue_create("Network Requests", DISPATCH_QUEUE_CONCURRENT)
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()

    // MARK: Handlers
    func GET(url: String, priority: Bool = false, success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation, NSError) -> Void)?) {
        self.request(url,
            method: "GET",
            priority: priority,
            success: success,
            failure: failure)
    }
    
    func request(url: String, method: String,  priority: Bool = false, success: ((AFHTTPRequestOperation, AnyObject) -> Void)?, failure: ((AFHTTPRequestOperation, NSError) -> Void)?) {
        var fullURL = url
        if !url.hasPrefix("http") {
            fullURL = "\(BulbapediaClient.baseURLString)/\(url)"
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: fullURL)!)
        request.HTTPMethod = method
        
        let operation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFOnoResponseSerializer.HTMLResponseSerializer()
        operation.setCompletionBlockWithSuccess(success, failure: failure)
        
        if priority {
            NSOperationQueue().addOperation(operation)
        } else {
            self.requestQueue.addOperation(operation)
        }
    }
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
