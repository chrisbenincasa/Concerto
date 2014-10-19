//
//  COPlaylist.swift
//  Concerto
//
//  Created by Christian Benincasa on 10/19/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COPlaylist: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var songs: NSSet
    @NSManaged var tags: NSSet

}
