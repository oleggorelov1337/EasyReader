//
//  DataManager.swift
//  EasyReader
//
//  Created by Oleg Gorelov on 09.05.17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import UIKit
import CoreData

class DataManager {
    
    static let sharedInstance = DataManager()
    
    private var fetcher = RSSFetcher()
    private var item: Item?
//    private var context: NSManagedObjectContext? =
//        ((UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext)
    private var context: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.getManagedObjectContext(withConcurrencyType: .privateQueueConcurrencyType)

    
    func searchRSSItems(completionHandler: @escaping (Bool) -> Void) {

        fetcher.getRSSData { [unowned unownedSelf = self]
            intermediateItems in
            
            if intermediateItems != nil, intermediateItems!.count > 0, unownedSelf.context != nil {
                Item.item(withIntermediateItems: intermediateItems!, inManagedObjectContext: unownedSelf.context!)
                try? unownedSelf.context?.save()
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        
    }
    
    func clearAllItems() {
        
        if context != nil {
            Item.clearItems(inManagedObjectContext: context!)
        }
        
    }
    

    
    
}
