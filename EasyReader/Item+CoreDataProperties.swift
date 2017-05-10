//
//  Item+CoreDataProperties.swift
//  EasyReader
//
//  Created by Oleg Gorelov on 09.05.17.
//  Copyright © 2017 Oleg Gorelov. All rights reserved.
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item");
    }

    @NSManaged public var title: String?
    @NSManaged public var descrip: String?
    @NSManaged public var link: String?
    @NSManaged public var pubDate: NSDate?
    @NSManaged public var creator: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var localImageURL: String?
    @NSManaged public var localThumbnailImageURL: String?

}
