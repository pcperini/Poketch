//
//  AppDelegate.swift
//  Poketch
//
//  Created by PATRICK PERINI on 3/3/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

import UIKit
import WatchConnectivity
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Properties
    var window: UIWindow?
    
    // MARK: Lifecycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        AppearanceSwizzling.setupAppearances()
        
        WCSession.defaultSession().delegate = self
        WCSession.defaultSession().activateSession()
        
        return true
    }
}

extension AppDelegate: WCSessionDelegate {
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        var response: [String: AnyObject] = [:]
        defer { replyHandler(response) }
        
        if let fetch = message["fetch"] as? [String: AnyObject] {
            guard let typeName = fetch["class"] as? String else {
                response = ["error": "invalid type"]
                return
            }
            
            let sortStateString = (fetch["sort"] as? String) ?? ""
            let sortState = SortState(rawValue: sortStateString)
            
            let offset = (fetch["offset"] as? Int) ?? 0
            let limit = (fetch["limit"] as? Int) ?? -1
            
            let results: [AnyObject]
            let total: Int
            
            switch typeName {
            case "PokedexEntry":
                let entries = self.handlePokedexEntriesFetch(sortState, limit: limit, offset: offset)
                results = entries.0.map { $0.structValue.transferableObject }
                total = entries.1
                
            default:
                results = []
                total = 0
            }
            
            response = [
                "results": results,
                "total": total
            ]
        }
    }
    
    func handlePokedexEntriesFetch(sort: SortState? = nil, limit: Int = -1, offset: Int = 0) -> ([PokedexEntry], Int) {
        let realm = try! Realm()
        var results = realm.objects(PokedexEntry).map { $0 }
        let total = results.count
        
        let stringCompare: (String, String) -> Bool = { (_0, _1) in
            _0.localizedCaseInsensitiveCompare(_1) == .OrderedAscending
        }
        
        if let sort = sort {
            switch sort {
            case .Region:
                results = results.sort {
                    if $0.0.identifier == 0 { return false }
                    return $0.0.identifier < $0.1.identifier
                }
                
            case .Alphabetical:
                results = results.sort { stringCompare($0.0.name, $0.1.name) }
                
            case .Type:
                results = results.sort { stringCompare($0.0.type1!.name, $0.1.type1!.name) }
            }
        }
        
        results = Array(results[offset ..< (results.count - offset)])
        if limit > 0 {
            results = Array(results[0 ..< min(limit, results.count)])
        }
        
        return (results, total)
    }
}

