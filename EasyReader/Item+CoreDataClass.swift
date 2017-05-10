//
//  Item+CoreDataClass.swift
//  EasyReader
//
//  Created by Oleg Gorelov on 09.05.17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import Foundation
import CoreData


public class Item: NSManagedObject {

//    class func item(withLink link: String?, inManagedObjectContext context: NSManagedObjectContext) -> Item? {
//        
//        let request = NSFetchRequest<Item>(entityName: "Item")
//        if let itemLink = link {
//            
//            request.predicate = NSPredicate(format: "link = %@", itemLink)
//            
//            if let item = (try? context.fetch(request))?.first {
//                return item
//            }
//        }
//        
//        return nil
//    }
    
    class func clearItems(inManagedObjectContext context: NSManagedObjectContext) {
        
        let fetchReuest = NSFetchRequest<Item>(entityName: "Item")
        
        if let results = try? context.fetch(fetchReuest) {
            for result in results {
                let managedObjectData:NSManagedObject = result as NSManagedObject
                context.delete(managedObjectData)
            }
            try? context.save()
        }
        
    }
    
    class func item(withIntermediateItems items: [IntermediateItem],
                    inManagedObjectContext context: NSManagedObjectContext) {
        
        for intermediateItem in items {
            
            let request = NSFetchRequest<Item>(entityName: "Item")
            if let itemLink = intermediateItem.link {
                
                request.predicate = NSPredicate(format: "link = %@", itemLink)
                
                if let item = (try? context.fetch(request))?.first {
                    
                } else if let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as? Item {
                    item.title = intermediateItem.title
                    item.descrip = intermediateItem.descrip
                    item.link = intermediateItem.link
                    item.creator = intermediateItem.creator
                    item.imageURL = intermediateItem.imageURL
                    item.localImageURL = intermediateItem.localImageURL
                    item.localThumbnailImageURL = intermediateItem.localThumbnailImageURL
                    item.pubDate = intermediateItem.pubDate
                }
            }
            
        }
        
    }
    
    class func item(withObjectID objectID: NSManagedObjectID, inManagedObjectContext context: NSManagedObjectContext) -> Item? {
        
        if let item = context.object(with: objectID) as? Item {
            return item
        }
        
        return nil
    }
    
    class func item(withTitle title: String?, inManagedObjectContext context: NSManagedObjectContext) -> Item? {
        
        let request = NSFetchRequest<Item>(entityName: "Item")
        if let itemTitle = title {
            
            request.predicate = NSPredicate(format: "title = %@", itemTitle)
            
            if let item = (try? context.fetch(request))?.first {
                return item
            } else if let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as? Item {
                item.title = title
                return item
            }
        }
        
        return nil
    }
    
    class func insertNewItem(inManagedObjectContext context: NSManagedObjectContext) -> Item? {
        
        if let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as? Item {
            return item
        }
        
        return nil
    }

    class func remove(item: Item, inManagedObjectContext context: NSManagedObjectContext) {
    
        context.delete(item)
    }
    
}
