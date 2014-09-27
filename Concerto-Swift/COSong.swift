//
//  COSong.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/21/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COSong: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var url: String
    @NSManaged var artist: COArtist

}
