//
//  COAlbum.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/19/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COAlbum: NSManagedObject {

    @NSManaged var lastModified: NSDate
    @NSManaged var name: String
    @NSManaged var year: NSNumber
    @NSManaged var artist: COArtist
    @NSManaged var songs: NSOrderedSet
    @NSManaged var tags: NSSet

}
