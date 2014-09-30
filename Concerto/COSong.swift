//
//  COSong.swift
//  Concerto-Swift
//
//  Created by Christian Benincasa on 9/28/14.
//  Copyright (c) 2014 Christian Benincasa. All rights reserved.
//

import Foundation
import CoreData

class COSong: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var bookmark: NSData
    @NSManaged var year: NSNumber
    @NSManaged var comment: String
    @NSManaged var trackNumber: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var composer: String
    @NSManaged var dateAdded: NSDate
    @NSManaged var bpm: NSNumber
    @NSManaged var fileType: String
    @NSManaged var artist: COArtist
    @NSManaged var album: COAlbum
    @NSManaged var tags: NSSet

}
