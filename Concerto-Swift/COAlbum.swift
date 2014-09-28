//
//  COAlbum.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COAlbum: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var lastModified: NSDate
    @NSManaged var year: NSNumber
    @NSManaged var songs: NSOrderedSet
    @NSManaged var tags: NSSet

}
