//
//  COTag.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COTag: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var songs: NSSet
    @NSManaged var albums: COAlbum

}
