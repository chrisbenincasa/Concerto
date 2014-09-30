//
//  COArtist.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COArtist: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var sortName: String
    @NSManaged var startYear: NSNumber
    @NSManaged var endYear: NSNumber
    @NSManaged var songs: NSSet

}
