//
//  COArtist.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/19/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COArtist: NSManagedObject {

    @NSManaged var endYear: NSNumber
    @NSManaged var name: String
    @NSManaged var sortName: String
    @NSManaged var startYear: NSNumber
    @NSManaged var albums: NSSet
    @NSManaged var songs: NSSet

}
